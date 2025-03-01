import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'dart:async';

void main() {
  runApp(StepCounterApp());
}

class StepCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StepCounterScreen(),
    );
  }
}

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  bool _isSensorAvailable = false;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<SensorEvent>? _accelerometerSubscription;
  double _lastX = 0.0, _lastY = 0.0, _lastZ = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initStepCounter();
    _initAccelerometer();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }
  }

  void _initAccelerometer() async {
    try {
      final available = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
      setState(() {
        _isSensorAvailable = available;
      });

      if (_isSensorAvailable) {
        _accelerometerSubscription = SensorManager()
            .sensorUpdates(sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL)
            .listen((event) {
          double x = event.data[0];
          double y = event.data[1];
          double z = event.data[2];

          double delta = (x - _lastX).abs() + (y - _lastY).abs() + (z - _lastZ).abs();
          if (delta > 1.5) {
            setState(() {
              _steps++;
            });
          }
          _lastX = x;
          _lastY = y;
          _lastZ = z;
        });
      } else {
        print("Accelerometer not available");
      }
    } catch (e) {
      print("Accelerometer Exception: $e");
    }
  }


  void _initAccelerometer() async {
    _isSensorAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
    if (_isSensorAvailable) {
      _accelerometerSubscription = SensorManager()
          .sensorUpdates(sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL)
          .handleError((error) {
        print("Accelerometer Error: $error");
      }).listen((event) {
        double x = event.data[0];
        double y = event.data[1];
        double z = event.data[2];

        double delta = (x - _lastX).abs() + (y - _lastY).abs() + (z - _lastZ).abs();
        if (delta > 1.5) {
          setState(() {
            _steps++;
          });
        }
        _lastX = x;
        _lastY = y;
        _lastZ = z;
      });
    } else {
      print("Accelerometer not available");
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Step Counter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Steps Taken:", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("$_steps", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(_isSensorAvailable ? "Accelerometer Available" : "Accelerometer Not Available",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

extension on Future<Stream<SensorEvent>> {
  handleError(Null Function(dynamic error) param0) {}
}
