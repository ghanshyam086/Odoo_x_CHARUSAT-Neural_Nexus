// import 'package:flutter/material.dart';
// import 'package:pedometer/pedometer.dart';
// import 'package:permission_handler/permission_handler.dart';
// // import 'package:flutter_sensors/flutter_sensors.dart';
// import 'dart:async';
// import 'dart:math';
//
// void main() {
//   // Ensure Flutter is initialized before running the app
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const StepCounterApp());
// }
//
// class StepCounterApp extends StatelessWidget {
//   const StepCounterApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StepCounterScreen(),
//     );
//   }
// }
//
// class StepCounterScreen extends StatefulWidget {
//   const StepCounterScreen({super.key});
//
//   @override
//   _StepCounterScreenState createState() => _StepCounterScreenState();
// }
//
// class _StepCounterScreenState extends State<StepCounterScreen> {
//   int _steps = 0;
//   bool _isPedometerAvailable = false;
//   bool _isAccelerometerAvailable = false;
//   StreamSubscription<StepCount>? _stepSubscription;
//   StreamSubscription<SensorEvent>? _accelerometerSubscription;
//
//   // Improved accelerometer step detection variables
//   List<double> _accelerometerValues = [0.0, 0.0, 0.0];
//   List<double> _accelHistory = [];
//   static const int _windowSize = 10;
//   double _peakThreshold = 12.0;
//   double _valleyThreshold = 8.0;
//   bool _isPeak = false;
//   bool _isValley = false;
//   DateTime? _lastStepTime;
//   static const int _minStepIntervalMs = 300;
//
//   bool _isInitialized = false;
//   String _statusMessage = 'Initializing sensors...';
//   String _errorMessage = '';
//   String _debugInfo = '';
//
//   @override
//   void initState() {
//     super.initState();
//     // Delay initialization to ensure the widget is fully built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeSensors();
//     });
//   }
//
//   Future<void> _initializeSensors() async {
//     if (_isInitialized) return;
//
//     try {
//       // First check and request permissions
//       bool permissionsGranted = await _requestPermissions();
//
//       if (!permissionsGranted) {
//         // If permissions weren't granted, don't try to initialize the sensors
//         return;
//       }
//
//       // Try to initialize both sensors
//       bool pedometerInitialized = await _initStepCounter();
//       bool accelerometerInitialized = await _initAccelerometer();
//
//       if (mounted) {
//         setState(() {
//           _isPedometerAvailable = pedometerInitialized;
//           _isAccelerometerAvailable = accelerometerInitialized;
//           _isInitialized = true;
//
//           if (pedometerInitialized) {
//             _statusMessage = 'Using pedometer sensor';
//           } else if (accelerometerInitialized) {
//             _statusMessage = 'Using accelerometer for steps';
//           } else {
//             _statusMessage = 'No step counting sensors available';
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _statusMessage = 'Initialization failed';
//           _errorMessage = 'Error: $e';
//           _debugInfo = 'Exception details: $e';
//         });
//       }
//     }
//   }
//
//   Future<bool> _requestPermissions() async {
//     try {
//       setState(() {
//         _debugInfo = 'Requesting permissions...';
//       });
//
//       // Request activity recognition permission
//       var activityStatus = await Permission.activityRecognition.request();
//
//       // On some devices, we need to request the sensors permission separately
//       var sensorStatus = await Permission.sensors.request();
//
//       if (!mounted) return false;
//
//       // Check results
//       bool allGranted = activityStatus.isGranted && sensorStatus.isGranted;
//
//       if (!allGranted) {
//         setState(() {
//           _statusMessage = 'Permission issue';
//           _errorMessage = 'Required permissions not granted';
//           _debugInfo = 'Activity: $activityStatus, Sensor: $sensorStatus';
//         });
//       } else {
//         setState(() {
//           _debugInfo = 'All permissions granted';
//         });
//       }
//
//       return allGranted;
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _statusMessage = 'Permission request failed';
//           _errorMessage = 'Error: $e';
//           _debugInfo = 'Permission exception: $e';
//         });
//       }
//       return false;
//     }
//   }
//
//   Future<bool> _initStepCounter() async {
//     try {
//       setState(() {
//         _debugInfo = 'Initializing pedometer...';
//       });
//
//       // Cancel existing subscription if any
//       await _stepSubscription?.cancel();
//
//       // Try to subscribe to the step counter
//       _stepSubscription = Pedometer.stepCountStream.listen(
//         _onStepCount,
//         onError: _onStepCountError,
//         onDone: _onStepCountDone,
//         cancelOnError: false,
//       );
//
//       setState(() {
//         _debugInfo = 'Pedometer initialized successfully';
//       });
//
//       return true;
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _debugInfo = 'Pedometer error details: $e';
//         });
//       }
//       return false;
//     }
//   }
//
//   void _onStepCount(StepCount event) {
//     if (!mounted) return;
//     setState(() {
//       // Make sure we don't decrease the steps if the pedometer resets
//       if (event.steps > _steps) {
//         _steps = event.steps;
//       }
//       _errorMessage = '';
//       _statusMessage = 'Using pedometer sensor';
//       _debugInfo = 'Step event: ${event.steps}';
//     });
//   }
//
//   void _onStepCountError(Object error) {
//     if (!mounted) return;
//     setState(() {
//       _isPedometerAvailable = false;
//       _debugInfo = 'Pedometer error details: $error';
//       _statusMessage = _isAccelerometerAvailable
//           ? 'Using accelerometer for steps'
//           : 'No step sensors available';
//     });
//   }
//
//   void _onStepCountDone() {
//     if (!mounted) return;
//     setState(() {
//       _isPedometerAvailable = false;
//       _debugInfo = 'Pedometer stream closed';
//       _statusMessage = _isAccelerometerAvailable
//           ? 'Using accelerometer for steps'
//           : 'No step sensors available';
//     });
//   }
//
//   Future<bool> _initAccelerometer() async {
//     try {
//       setState(() {
//         _debugInfo = 'Initializing accelerometer...';
//       });
//
//       await _accelerometerSubscription?.cancel();
//
//       final isAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
//       if (!mounted) return false;
//
//       if (!isAvailable) {
//         setState(() {
//           _isAccelerometerAvailable = false;
//           _debugInfo = 'Accelerometer not available on this device';
//         });
//         return false;
//       }
//
//       final stream = await SensorManager().sensorUpdates(
//         sensorId: Sensors.ACCELEROMETER,
//         interval: Sensors.SENSOR_DELAY_NORMAL,
//       );
//
//       _accelerometerSubscription = stream.listen(
//         _onAccelerometerData,
//         onError: _onAccelerometerError,
//         onDone: _onAccelerometerDone,
//         cancelOnError: false,
//       );
//
//       setState(() {
//         _isAccelerometerAvailable = true;
//         _debugInfo = 'Accelerometer initialized successfully';
//       });
//
//       return true;
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isAccelerometerAvailable = false;
//           _debugInfo = 'Accelerometer error details: $e';
//         });
//       }
//       return false;
//     }
//   }
//
//   void _onAccelerometerData(SensorEvent event) {
//     if (!mounted) return;
//
//     // Skip accelerometer processing if pedometer is working
//     if (_isPedometerAvailable) return;
//
//     try {
//       // Update accelerometer values
//       _accelerometerValues = [event.data[0], event.data[1], event.data[2]];
//
//       // Calculate magnitude of acceleration (removing gravity)
//       double magnitude = sqrt(
//           _accelerometerValues[0] * _accelerometerValues[0] +
//               _accelerometerValues[1] * _accelerometerValues[1] +
//               _accelerometerValues[2] * _accelerometerValues[2]
//       );
//
//       // Add to history and keep only the latest values
//       _accelHistory.add(magnitude);
//       if (_accelHistory.length > _windowSize) {
//         _accelHistory.removeAt(0);
//       }
//
//       // Need enough samples to detect steps
//       if (_accelHistory.length >= _windowSize) {
//         double avg = _accelHistory.reduce((a, b) => a + b) / _accelHistory.length;
//
//         // Peak detection
//         if (magnitude > _peakThreshold && !_isPeak && !_isValley) {
//           _isPeak = true;
//           setState(() {
//             _debugInfo = 'Peak detected: ${magnitude.toStringAsFixed(2)}';
//           });
//         }
//
//         // Valley detection after peak
//         if (_isPeak && magnitude < _valleyThreshold) {
//           _isValley = true;
//           setState(() {
//             _debugInfo = 'Valley detected: ${magnitude.toStringAsFixed(2)}';
//           });
//         }
//
//         // Step is complete when we see peak followed by valley
//         if (_isPeak && _isValley) {
//           DateTime now = DateTime.now();
//           if (_lastStepTime == null ||
//               now.difference(_lastStepTime!).inMilliseconds > _minStepIntervalMs) {
//             setState(() {
//               _steps++;
//               _lastStepTime = now;
//               _debugInfo = 'Step detected! Total: $_steps';
//             });
//           }
//
//           // Reset detection state
//           _isPeak = false;
//           _isValley = false;
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _debugInfo = 'Accelerometer data error: $e';
//       });
//     }
//   }
//
//   void _onAccelerometerError(Object error) {
//     if (!mounted) return;
//     setState(() {
//       _isAccelerometerAvailable = false;
//       _debugInfo = 'Accelerometer error: $error';
//       if (!_isPedometerAvailable) {
//         _statusMessage = 'No step sensors available';
//       }
//     });
//   }
//
//   void _onAccelerometerDone() {
//     if (!mounted) return;
//     setState(() {
//       _isAccelerometerAvailable = false;
//       _debugInfo = 'Accelerometer stream closed';
//       if (!_isPedometerAvailable) {
//         _statusMessage = 'No step sensors available';
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _stepSubscription?.cancel();
//     _accelerometerSubscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Step Counter"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.directions_walk,
//               size: 70,
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Steps Taken:",
//               style: TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "$_steps",
//               style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(10),
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontStyle: FontStyle.italic,
//                   color: _isPedometerAvailable || _isAccelerometerAvailable
//                       ? Colors.green
//                       : Colors.orange,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 10),
//             if (_errorMessage.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 child: Text(
//                   _errorMessage,
//                   style: const TextStyle(color: Colors.red, fontSize: 14),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             const SizedBox(height: 5),
//             Container(
//               padding: const EdgeInsets.all(10),
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Debug Info:",
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _debugInfo,
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _steps = 0;
//                       _lastStepTime = null;
//                       _errorMessage = '';
//                       _debugInfo = 'Steps reset to 0';
//                     });
//                   },
//                   icon: const Icon(Icons.refresh),
//                   label: const Text("Reset Steps"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 TextButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _isInitialized = false;
//                       _debugInfo = 'Reinitializing sensors...';
//                     });
//                     _initializeSensors();
//                   },
//                   icon: const Icon(Icons.sensors),
//                   label: const Text("Retry Sensors"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }