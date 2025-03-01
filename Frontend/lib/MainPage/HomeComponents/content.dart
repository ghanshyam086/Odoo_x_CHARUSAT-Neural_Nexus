import 'package:flutter/material.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Content Page! This page will display health and wellness content.',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}