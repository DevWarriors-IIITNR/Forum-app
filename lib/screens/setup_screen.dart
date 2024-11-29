import 'package:flutter/material.dart';
import 'package:attendance_tracker/database/database_helper.dart';
// import 'package:attendance_tracker/screens/dashboard_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  // Load subjects from the database
  void _loadSubjects() async {
    final data = await DatabaseHelper.instance.fetchSubjects();
    setState(() {
      _subjects = data;
    });
  }

  // Add a new subject to the database
  void _addSubject() async {
    if (_formKey.currentState!.validate()) {
      // Check for duplicate subject name
      if (_subjects.any((subject) =>
          subject['name'].toLowerCase() ==
          _subjectController.text.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject already exists!')),
        );
        return;
      }

      // Insert subject into the database
      await DatabaseHelper.instance.insertSubject({
        'name': _subjectController.text,
        'totalLectures': 0,
        'attendedLectures': 0,
      });

      _subjectController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Subject added!')));
      _loadSubjects(); // Refresh the subject list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Setup Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input Form
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a subject name' : null,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSubject,
              child: Text('Add Subject'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Added Subjects:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Display List of Added Subjects
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  return ListTile(
                    title: Text(subject['name']),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dashboard');
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
