import 'package:flutter/material.dart';
import 'package:attendance_tracker/database/database_helper.dart';
import 'package:attendance_tracker/screens/add_lecture_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> subjects = [];

  void _loadSubjects() async {
    final data = await DatabaseHelper.instance.fetchSubjects();
    setState(() {
      subjects = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  double _calculateAttendance(int attended, int total) {
    return total == 0 ? 0 : (attended / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final attendance = _calculateAttendance(
              subject['attendedLectures'], subject['totalLectures']);

          return ListTile(
            title: Text(subject['name']),
            subtitle: Text('Attendance: ${attendance.toStringAsFixed(1)}%'),
            tileColor: attendance < 75 ? Colors.red[100] : Colors.green[100],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLectureScreen(subject: subject),
                ),
              ).then((_) => _loadSubjects()); // Refresh the dashboard on return
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
