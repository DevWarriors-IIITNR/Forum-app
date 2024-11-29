import 'package:flutter/material.dart';
import 'package:attendance_tracker/database/database_helper.dart';

class AddLectureScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const AddLectureScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _AddLectureScreenState createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  late int totalLectures;
  late int attendedLectures;
  final List<Map<String, int>> _historyStack = [];

  @override
  void initState() {
    super.initState();
    totalLectures = widget.subject['totalLectures'];
    attendedLectures = widget.subject['attendedLectures'];
  }

  void _markAttendance(bool present) async {
    // Save the current state for undo
    _historyStack.add({
      'totalLectures': totalLectures,
      'attendedLectures': attendedLectures,
    });

    setState(() {
      totalLectures++;
      if (present) attendedLectures++;
    });

    // Update the database
    await DatabaseHelper.instance.updateSubject({
      'name': widget.subject['name'],
      'totalLectures': totalLectures,
      'attendedLectures': attendedLectures,
    }, widget.subject['id']);
  }

  void _undoLastAction() async {
    if (_historyStack.isNotEmpty) {
      // Revert to the most recent state
      final previousState = _historyStack.removeLast();

      setState(() {
        totalLectures = previousState['totalLectures']!;
        attendedLectures = previousState['attendedLectures']!;
      });

      // Update the database
      await DatabaseHelper.instance.updateSubject({
        'name': widget.subject['name'],
        'totalLectures': totalLectures,
        'attendedLectures': attendedLectures,
      }, widget.subject['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Undo successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No more actions to undo!')),
      );
    }
  }

  double _calculateAttendance() {
    return totalLectures == 0 ? 0 : (attendedLectures / totalLectures) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject['name'])),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Total Lectures: $totalLectures',
                    style: TextStyle(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Attended Lectures: $attendedLectures',
                    style: TextStyle(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Attendance: ${_calculateAttendance().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      color: _calculateAttendance() < 75
                          ? Colors.red
                          : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _markAttendance(true),
                    icon: Icon(Icons.check),
                    label: Text('Mark Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _markAttendance(false),
                    icon: Icon(Icons.close),
                    label: Text('Mark Absent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _historyStack.isEmpty ? null : _undoLastAction,
                    icon: Icon(Icons.undo),
                    label: Text('Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
