import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StepCounterApp());
}

class StepCounterApp extends StatelessWidget {
  const StepCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StepCounterScreen(),
    );
  }
}

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  bool _isPedometerAvailable = false;
  StreamSubscription<StepCount>? _stepSubscription;

  String _statusMessage = 'Initializing pedometer...';
  String _errorMessage = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePedometer();
    });
  }

  Future<void> _initializePedometer() async {
    if (_isPedometerAvailable) return;

    try {
      // Request necessary permissions
      bool permissionsGranted = await _requestPermissions();

      if (!permissionsGranted) {
        setState(() {
          _statusMessage = 'Permission issue';
          _errorMessage = 'Required permissions not granted';
          _debugInfo = 'Permission denied';
        });
        return;
      }

      // Initialize pedometer
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        onDone: _onStepCountDone,
        cancelOnError: false,
      );

      setState(() {
        _isPedometerAvailable = true;
        _statusMessage = 'Pedometer initialized successfully';
        _debugInfo = 'Pedometer stream active';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization failed';
        _errorMessage = 'Error: $e';
        _debugInfo = 'Exception details: $e';
      });
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      setState(() {
        _debugInfo = 'Requesting permissions...';
      });

      var activityStatus = await Permission.activityRecognition.request();
      var sensorStatus = await Permission.sensors.request();

      if (!mounted) return false;

      bool allGranted = activityStatus.isGranted && sensorStatus.isGranted;

      if (!allGranted) {
        setState(() {
          _errorMessage = 'Required permissions not granted';
          _debugInfo = 'Activity: $activityStatus, Sensor: $sensorStatus';
        });
        // Open app settings if permissions are denied permanently
        if (activityStatus.isPermanentlyDenied || sensorStatus.isPermanentlyDenied) {
          openAppSettings();
        }
      } else {
        setState(() {
          _debugInfo = 'All permissions granted';
        });
      }

      return allGranted;
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Permission request failed';
          _errorMessage = 'Error: $e';
          _debugInfo = 'Permission exception: $e';
        });
      }
      return false;
    }
  }

  void _onStepCount(StepCount event) {
    if (!mounted) return;
    setState(() {
      // Ensure steps don't decrease
      if (event.steps > _steps) {
        _steps = event.steps;
      }
      _errorMessage = '';
      _statusMessage = 'Tracking steps with pedometer';
      _debugInfo = 'Step event: ${event.steps} at ${event.timeStamp}';
    });
  }

  void _onStepCountError(Object error) {
    if (!mounted) return;
    setState(() {
      _isPedometerAvailable = false;
      _statusMessage = 'Pedometer error occurred';
      _errorMessage = 'Error: $error';
      _debugInfo = 'Pedometer error details: $error';
    });
  }

  void _onStepCountDone() {
    if (!mounted) return;
    setState(() {
      _isPedometerAvailable = false;
      _statusMessage = 'Pedometer stream closed';
      _debugInfo = 'Pedometer stream ended';
    });
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step Counter"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_walk,
              size: 70,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Steps Taken:",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              "$_steps",
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: _isPedometerAvailable ? Colors.green : Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    "Debug Info:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _debugInfo,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _steps = 0;
                      _errorMessage = '';
                      _debugInfo = 'Steps reset to 0';
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Steps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _initializePedometer,
                  icon: const Icon(Icons.sensors),
                  label: const Text("Retry Sensors"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}