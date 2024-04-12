import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:swipe_aid/views/sensors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Collision extends StatefulWidget {
  final double speed;
  final double leftSpeed;
  final double rightSpeed;
  final String atFault;
  final String preventiveMeasure;
  final Map<String, Map<String, dynamic>> sensorData;

  const Collision({
    Key? key,
    required this.speed,
    required this.leftSpeed,
    required this.rightSpeed,
    required this.atFault,
    required this.preventiveMeasure,
    required this.sensorData,
  }) : super(key: key);

  @override
  State<Collision> createState() => _CollisionState();
}

class _CollisionState extends State<Collision> {
  // String apiUrl  =  ""
  Map<String, dynamic> _response = {"fault": "", "prevention": ""};
  Future<void> _postData() async {
    print("testing");
    final String apiUrl = 'http://172.20.10.4:8080/runmodel';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "Self Speed": widget.speed,
          "Right Speed": widget.rightSpeed,
          "Left Speed": widget.leftSpeed,
          "Left Front Distance": widget.sensorData.containsKey("Front Left")
              ? widget.sensorData["Front Left"]!["value"]
              : "0",
          "Right Front Distance": widget.sensorData.containsKey("Front Right")
              ? widget.sensorData["Front Right"]!["value"]
              : "0",
          "Left Back Distance": widget.sensorData.containsKey("Back Left")
              ? widget.sensorData["Back Left"]!["value"]
              : "0",
          "Right Back Distance": widget.sensorData.containsKey("Back Right")
              ? widget.sensorData["Back Right"]!["value"]
              : "0"
        }),
      );

      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        setState(() {
          // result = 'ID: ${responseData['id']}\nName: ${responseData['name']}\nEmail: ${responseData['email']}';
          _response = {
            "fault": responseData['fault'],
            "prevention": responseData['prevention']
          };
        });
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to post data');
      }
    } catch (e) {
      // setState(() {
      //   _response = 'Error: $e';
      // });
      throw Exception('Error with api $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _postData(); // Call the post request when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    // Access the sensor data from SensorDataProvider
    Map<String, Map<String, dynamic>> sensorData = widget.sensorData;

    return Scaffold(
      backgroundColor: Color(0xFF1B1B1E),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Collision Summary",
          style: TextStyle(color: Color(0xFFFBFFFE)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Text('Test: ${_response}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  child: Column(
                children: <Widget>[
                  SimpleCircularProgressBar(
                    size: 45,
                    backStrokeWidth: 5,
                    valueNotifier: ValueNotifier(widget.speed),
                    mergeMode: true,
                    onGetText: (double value) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text('My Speed',
                      style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 14)),
                ],
              )),
              Container(
                  child: Column(
                children: <Widget>[
                  SimpleCircularProgressBar(
                    size: 45,
                    backStrokeWidth: 5,
                    valueNotifier: ValueNotifier(widget.rightSpeed),
                    mergeMode: true,
                    onGetText: (double value) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text('right Speed',
                      style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 14)),
                ],
              )),
              Container(
                  child: Column(
                children: <Widget>[
                  SimpleCircularProgressBar(
                    size: 45,
                    backStrokeWidth: 5,
                    valueNotifier: ValueNotifier(widget.leftSpeed),
                    mergeMode: true,
                    onGetText: (double value) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text('Left Speed',
                      style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 14)),
                ],
              )),
            ],
          ),
          Padding(padding: EdgeInsetsDirectional.all(20)),
          Text(
              'Front Left: ${sensorData.containsKey("Front Left") ? sensorData["Front Left"]!["value"] : "0"}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text(
              'Back Left: ${sensorData.containsKey("Back Left") ? sensorData["Back Left"]!["value"] : "0"}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text(
              'Front Right: ${sensorData.containsKey("Front Right") ? sensorData["Front Right"]!["value"] : "0"}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text(
              'Back Right: ${sensorData.containsKey("Back Right") ? sensorData["Back Right"]!["value"] : "0"}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text(
              'Approximate Time of Impact: ${sensorData.containsKey("Back Right") ? sensorData["Back Right"]!["value"] : DateTime.now()}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text('At Fault (suggested): ${_response['fault']}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
          Text('Preventive Measure (suggested): ${_response['prevention']}',
              style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 16)),
          Padding(padding: EdgeInsetsDirectional.all(10)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          // _postData();
        },
        child: Icon(Icons.arrow_left),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
