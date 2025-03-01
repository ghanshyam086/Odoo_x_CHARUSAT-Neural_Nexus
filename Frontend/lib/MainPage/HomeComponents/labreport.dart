import 'package:flutter/material.dart';

class LabReportPage extends StatelessWidget {
  const LabReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Reports'),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Lab Reports Page! This page will display lab test results.',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}