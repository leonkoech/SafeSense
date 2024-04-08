import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:swipe_aid/views/collision.dart';

import '../components/CarBorder.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CarMode extends StatefulWidget {
  const CarMode({super.key});

  @override
  State<CarMode> createState() => _CarModeState();
}

class _CarModeState extends State<CarMode> {
  final StreamController<double> _speedController = StreamController<double>();

  Stream<double> get speedStream => _speedController.stream;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _speedController.close();
    super.dispose();
  }

  void _startListening() async {
    try {
      Position position = await _determinePosition();
      findDistance(position);
    } catch (e) {
      // Handle error (e.g., location services disabled, permissions denied)
      print('Error: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: locationSettings.accuracy);
  }

  void findDistance(Position initialPosition) {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      // Convert speed from m/s to mph
      double speedMph = position.speed * 2.23694;
      _speedController.add(speedMph);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1B1E),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Car Mode",
          style: TextStyle(color: Color(0xFFFBFFFE)),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 70),
            child: StreamBuilder<double>(
              stream: speedStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(' ${snapshot.data?.toStringAsFixed(2)} mph',
                      style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 30));
                } else {
                  return const Text('Waiting for speed data...',
                      style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 30));
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 70),
              // height: MediaQuery.of(context).size.height-30,
              // alignment: Alignment.center,
              // color: Colors.red,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Stack(
                      children: <Widget>[
                        CustomBorderContainer(
                          left: 20,
                          bottom: 20,
                          distance: 0.5,
                        ),
                        CustomBorderContainer(
                          right: 20,
                          top: 20,
                          distance: 0.4,
                        ),
                        CustomBorderContainer(
                          right: 20,
                          bottom: 20,
                          distance: 0.2,
                        ),
                        CustomBorderContainer(
                          left: 20,
                          top: 20,
                          distance: 0.2,
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/car 1.png",
                      // height: MediaQuery.of(context).size.height-30,
                      fit: BoxFit.fitHeight,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Collision()),
          );
        },
        child: Icon(Icons.arrow_right), // You can change the icon
        backgroundColor: Colors.blue, // You can change the background color
      ),
    );
  }
}

// class SensorData extends StatelessWidget {
//   const SensorData({super.key});

//   @override
//   Widget build(BuildContext context){

//   }
// }
