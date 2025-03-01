import 'package:fitsync/MainPage/Home.dart';
import 'package:fitsync/PortSection/ConfigFile.dart';
import 'package:fitsync/Step_Counter.dart';
import 'package:flutter/material.dart';
import './LoginSignupCompnent/LoginPage.dart';
import './MainPage/Home.dart';
import 'hospital_finder/hospital_finder_screen.dart';
import 'package:fitsync/StepCounter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Sync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade800,
          secondary: Colors.teal.shade600,
        ),
        useMaterial3: true,
      ),
      home:  const LoginPage()
    );
  }
}