import 'package:flutter/material.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TimetablePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> timeSlots = [
    '8-9am',
    '9-10am',
    '10-11am',
    '12-1pm',
    'Lunch',
    '2-3pm',
    '3-4pm',
    '4-5pm',
    '5-6pm'
  ];

  // Timetable structure: day -> time slot -> subject
  Map<String, Map<String, String>> timetable = {};

  void initializeTimetable() {
    for (var day in days) {
      timetable[day] = {};
      for (var slot in timeSlots) {
        timetable[day]![slot] = '';
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeTimetable();
  }

  void navigateToAttendancePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(timetable: timetable),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Setup Timetable')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 100,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Day/Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...timeSlots.map((slot) => Container(
                  width: 100,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    slot,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
            // Timetable Rows
            ...days.map((day) {
              return Row(
                children: [
                  // Day Column
                  Container(
                    width: 100,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      day,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Time Slot Input Columns
                  ...timeSlots.map((slot) {
                    return Container(
                      width: 100,
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Subject'),
                        onChanged: (value) {
                          timetable[day]![slot] = value;
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAttendancePage,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final Map<String, Map<String, String>> timetable;

  AttendancePage({required this.timetable});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Map<String, Map<String, bool>> attendance = {};
  final Map<String, Map<String, int>> attendanceStats = {};

  @override
  void initState() {
    super.initState();
    initializeAttendance();
  }

  void initializeAttendance() {
    widget.timetable.forEach((day, slots) {
      attendance[day] = {};
      attendanceStats[day] = {};
      slots.forEach((slot, subject) {
        if (subject.isNotEmpty) {
          attendance[day]![slot] = false;
          if (!attendanceStats.containsKey(subject)) {
            attendanceStats[subject] = {'attended': 0, 'total': 0};
          }
        }
      });
    });
  }

  void markAttendance(String day, String slot, bool present) {
    final subject = widget.timetable[day]![slot]!;
    if (subject.isNotEmpty) {
      setState(() {
        if (present) {
          attendanceStats[subject]!['attended'] = (attendanceStats[subject]!['attended'] ?? 0) + 1;
        }
        attendanceStats[subject]!['total'] = (attendanceStats[subject]!['total'] ?? 0) + 1;
        attendance[day]![slot] = present;
      });
    }
  }

  double calculatePercentage(String subject) {
    final stats = attendanceStats[subject];
    if (stats == null || stats['total'] == 0) return 0.0;
    return (stats['attended']! / stats['total']!) * 100;
  }

  void showAttendanceSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Attendance Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: attendanceStats.keys.map((subject) {
              final percentage = calculatePercentage(subject).toStringAsFixed(2);
              return ListTile(
                title: Text(subject),
                subtitle: Text('Attendance: $percentage%'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take Attendance')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: widget.timetable.keys.map((day) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.timetable[day]!.keys.map((slot) {
                final subject = widget.timetable[day]![slot]!;
                if (subject.isEmpty) return SizedBox();
                return Row(
                  children: [
                    Expanded(child: Text('$slot: $subject')),
                    Checkbox(
                      value: attendance[day]![slot] ?? false,
                      onChanged: (value) {
                        markAttendance(day, slot, value!);
                      },
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAttendanceSummary,
        child: Icon(Icons.check),
      ),
    );
  }
}
