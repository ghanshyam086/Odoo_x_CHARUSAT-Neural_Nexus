import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import 'package:fitsync/PortSection/ConfigFile.dart';
import '../MainPage/Home.dart'; // Import HomePage for navigation

class StepCounter extends StatefulWidget {
  final String userId;
  final Function(int) onStepUpdate;
  final Map<String, dynamic>? initialUserData; // Nullable to match ProfilePage
  const StepCounter({
    super.key,
    required this.userId,
    required this.onStepUpdate,
    this.initialUserData,
  });

  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int stepsTaken = 0;
  int stepGoal = 1000;
  bool isLoading = true;
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  void initState() {
    super.initState();
    _initializePedometer();
    _fetchSteps(); // Fetch initial data from server
  }

  Future<void> _initializePedometer() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } else {
      print('Permission denied for activity recognition');
      setState(() { isLoading = false; });
    }
  }

  void _onStepCount(StepCount event) {
    if (mounted) {
      setState(() {
        // Update stepsTaken with live data, assuming event.steps is cumulative
        if (event.steps > stepsTaken) {
          stepsTaken = event.steps;
          widget.onStepUpdate(stepsTaken); // Notify parent widget
          _submitSteps(); // Auto-submit live steps to server
        }
      });
    }
  }

  void _onStepCountError(Object error) {
    if (mounted) {
      print('Step counting error: $error');
    }
  }

  Future<void> _fetchSteps() async {
    try {
      final response = await http.get(Uri.parse('$getSteps${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stepsTaken = data['stepsTaken'] ?? 0;
          stepGoal = data['todayStepGoal'] ?? 1000;
          isLoading = false;
        });
      } else {
        print('Failed to fetch steps: ${response.statusCode}');
        setState(() { isLoading = false; });
      }
    } catch (e) {
      print('Error fetching steps: $e');
      setState(() { isLoading = false; });
    }
  }

  Future<void> _submitSteps() async {
    try {
      final response = await http.post(
        Uri.parse(submitSteps),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId, 'stepsTaken': stepsTaken}),
      );
      if (response.statusCode == 201) {
        print('Steps submitted successfully: $stepsTaken');
      } else {
        print('Failed to submit steps: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting steps: $e');
    }
  }

  void _resetSteps() {
    setState(() {
      stepsTaken = 0;
    });
    _submitSteps(); // Sync reset with server
    widget.onStepUpdate(0); // Notify parent widget
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = stepsTaken / stepGoal;
    if (progress > 1) progress = 1;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              const Text(
                'Daily Step Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$stepsTaken",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const Text(
                      "Steps",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Colors.teal),
                minHeight: 10,
              ),
              const SizedBox(height: 10),
              Text(
                '$stepsTaken / $stepGoal steps',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _resetSteps,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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