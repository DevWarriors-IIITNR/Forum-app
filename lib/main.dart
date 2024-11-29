import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(AttendanceTrackerApp());
}

class AttendanceTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SetupScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}

