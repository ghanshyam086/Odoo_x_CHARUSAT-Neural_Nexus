import 'package:flutter/material.dart';

class NearbyDoctorsPage extends StatelessWidget {
  const NearbyDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Doctors'),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Nearby Doctors Page! This page will show nearby healthcare providers.',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}