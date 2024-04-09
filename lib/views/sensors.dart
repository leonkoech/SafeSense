import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_aid/components/CarBorder.dart';
// import 'package:swipe_aid/views/car.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:swipe_aid/views/collision.dart';

import '../components/CarBorder.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Map<String, String> bluetoothMap = {
  'E8:6B:EA:D3:70:46': 'Front Left',
  'E8:6B:EA:D4:01:EA': 'Front Right',
  'EC:64:C9:86:62:02': 'Back Left',
  'E0:6B:EA:D3:70:46': 'Back Right',
  'key3': 'unknown',
};

SensorName(String ID) {
  return getValueFromMapOrFallback(bluetoothMap, ID, 'key3');
}

displaySensor(String SensorName) {
  return SensorName != 'unknown';
}

void automaticConnect(BluetoothDevice device) {
  if (displaySensor(SensorName(device.remoteId.toString()))) {
    device.connect();
    print(device.remoteId.toString() + "connected");
  }
  // widget.device.connect()
}

class Sensors extends StatefulWidget {
  const Sensors({Key? key}) : super(key: key);

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _startBluetoothScan();
  }

  Future<void> _initializeBluetooth() async {
    // Request Bluetooth permissions
    var bluetoothPermissions = await Permission.bluetooth.request();
    var bluetoothConnectPermissions =
        await Permission.bluetoothConnect.request();

    if (bluetoothPermissions.isGranted &&
        bluetoothConnectPermissions.isGranted) {
      // Bluetooth permissions granted, enable Bluetooth
      await _enableBluetooth();
    } else {
      // Permissions not granted, handle accordingly (e.g., show error message)
      print('Bluetooth permissions not granted');
    }
  }

  Future<void> _enableBluetooth() async {
    // First, check if Bluetooth is supported by your hardware
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // Handle Bluetooth on & off
    // Your existing Bluetooth initialization code here...
  }

  List<BluetoothDevice> devices = [];

  void _startBluetoothScan() async {
    // Start scanning for Bluetooth devices
    FlutterBluePlus.scanResults.listen((scanResult) {
      for (ScanResult result in scanResult) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });

    // Start the scan
    FlutterBluePlus.startScan();
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
            "Sensor Connection",
            style: TextStyle(color: Color(0xFFFBFFFE)),
          ),
        ),
        body: BluetoothDeviceList(
          devices: devices,
        ),
        floatingActionButton: Column(
            //  verticalDirection: Ver,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  for (BluetoothDevice device in devices) {
                    String sensorName = SensorName(device.remoteId.toString());
                    if (displaySensor(sensorName)) {
                    Fluttertoast.showToast(
                        msg: 'Reconnecting ',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    automaticConnect(device);
                    }

                  }
                },
                child: Icon(Icons.refresh), // You can change the icon
                backgroundColor:
                    Colors.blue, // You can change the background color
              ),
              FloatingActionButton(
                onPressed: () {
                  // Add your action here
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Collision()),
                  );
                },
                child: Icon(Icons.refresh), // You can change the icon
                backgroundColor:
                    Colors.blue, // You can change the background color
              ),
            ]));
  }
}

class BluetoothDeviceList extends StatefulWidget {
  final List<BluetoothDevice> devices;

  const BluetoothDeviceList({super.key, required this.devices});

  @override
  _BluetoothDeviceListState createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends State<BluetoothDeviceList> {
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

  //  List<CustomBorderContainerConfig> containerConfigs

  List<Widget> DevicesList() {
    List<Widget> deviceList = [];
    for (var device in widget.devices) {
      if (displaySensor(SensorName(device.remoteId.toString()))) {
        deviceList.add(SensorRepresentation(device: device));
      }
    }
    return deviceList;
  }

  @override
  Widget build(BuildContext context) {
    // return ListView.builder(
    //   itemCount: widget.devices.length,
    //   itemBuilder: (context, index) {
    //     return SensorRepresentation(device: widget.devices[index]);
    //   },
    // );
    return Center(
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
                  Stack(children: DevicesList()),
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
    ));
  }
}

class SensorRepresentation extends StatefulWidget {
  final BluetoothDevice device;
  // final String id;
  SensorRepresentation({required this.device});

  @override
  _SensorRepresentationState createState() => _SensorRepresentationState();
}

class _SensorRepresentationState extends State<SensorRepresentation> {
  late StreamSubscription<BluetoothConnectionState> _connectionSubscription;
  Map<String, StreamSubscription<List<int>>> _dataSubscriptions = {};

  double distance = 1.0;
// Map<String, StreamSubscription<List<int>>> _dataSubscriptions = {};

  double parseDoubleSafely(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      // Handle the exception, e.g., return a default value or rethrow the exception.
      print("Error parsing double: $e");
      return 0.0; // Return a default value or any other meaningful value.
    }
  }

  Future<void> _startReadingData() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify ||
            characteristic.properties.indicate) {
          await characteristic.setNotifyValue(true);
          _dataSubscriptions[characteristic.uuid.toString()] =
              characteristic.value.listen((value) {
            List<int> receivedData = value;
            String decodedString = String.fromCharCodes(receivedData);
            distance = (parseDoubleSafely(decodedString) / 100);
            print('Received data from ${widget.device.remoteId}: $distance');

            // Process received data here
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    automaticConnect(widget.device);
    _connectionSubscription =
        widget.device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        await _startReadingData();
        // turn flag to true for data based on a map
      }
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _dataSubscriptions.forEach((_, subscription) {
      subscription.cancel();
    });
    super.dispose();
  }

  Widget customContainer(double distance) {
    String sensorName = SensorName(widget.device.remoteId.toString());
    Widget currentWidget = const SizedBox();
    switch (sensorName) {
      case 'Front Left':
        currentWidget = CustomBorderContainer(
          left: 20,
          top: 20,
          distance: distance,
        );
        break;
      case 'Front Right':
        currentWidget = CustomBorderContainer(
          right: 20,
          top: 20,
          distance: distance,
        );
        // do something
        break;
      case 'Back Left':
        currentWidget = CustomBorderContainer(
          left: 20,
          bottom: 20,
          distance: distance,
        );
        // do something
        break;
      case 'Back Right':
        currentWidget = CustomBorderContainer(
          bottom: 20,
          right: 20,
          distance: distance,
        );
        // do something
        break;
      case "unknown":
        currentWidget = const SizedBox();
        break;
      // do something else
    }
    return currentWidget;
  }

  @override
  Widget build(BuildContext context) {
    return customContainer(distance);
  }
}

dynamic getValueFromMapOrFallback(
    Map<dynamic, dynamic> map, dynamic key, dynamic fallbackKey) {
  if (map.containsKey(key)) {
    return map[key];
  } else if (map.containsKey(fallbackKey)) {
    return map[fallbackKey];
  } else {
    return null; // or any default value you want to return
  }
}
