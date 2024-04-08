import 'package:flutter/material.dart';
import 'package:swipe_aid/views/sensors.dart';
// import './views/sensors.dart';
// import './views/collision.dart';
// import './views/carmode.dart';
import 'package:swipe_aid/views/car.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 189, 204, 253)),
        useMaterial3: true,
      ),
      home: Sensors(),
    );
  }
}

