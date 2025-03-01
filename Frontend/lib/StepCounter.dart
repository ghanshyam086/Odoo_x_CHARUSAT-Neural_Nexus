import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StepCounter extends StatefulWidget {
  final String userId;
  final Function(int) onStepUpdate;
  const StepCounter({super.key, required this.userId, required this.onStepUpdate});

  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int stepsTaken = 0;
  int stepGoal = 50000;
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSteps();
  }

  Future<void> _fetchSteps() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.218.120:3000/api/steps/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stepsTaken = data['stepsTaken'] ?? 0;
          stepGoal = data['todayStepGoal'] ?? 50000;
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
    final steps = int.tryParse(_controller.text) ?? 0;
    try {
      final response = await http.post(
        Uri.parse('http://172.16.218.120:3000/api/steps'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId, 'stepsTaken': steps}),
      );
      if (response.statusCode == 201) {
        setState(() {
          stepsTaken = steps;
        });
        widget.onStepUpdate(steps); // Notify ProfilePage to refresh streaks
        _controller.clear();
      } else {
        print('Failed to submit steps: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting steps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = stepsTaken / stepGoal;
    if (progress > 1) progress = 1;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const Text('Daily Step Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
            const SizedBox(height: 10),
            Text('$stepsTaken / $stepGoal steps'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter steps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submitSteps,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}