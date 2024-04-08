import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_aid/views/car.dart';

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
      body: BluetoothDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CarMode()),
          );
        },
        child: Icon(Icons.arrow_right), // You can change the icon
        backgroundColor: Colors.blue, // You can change the background color
      ),
    );
  }
}

class BluetoothDeviceList extends StatefulWidget {
  @override
  _BluetoothDeviceListState createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends State<BluetoothDeviceList> {
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _startBluetoothScan();
  }

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
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return BluetoothDeviceButton(device: devices[index]);
      },
    );
  }
}

class BluetoothDeviceButton extends StatefulWidget {
  final BluetoothDevice device;

  BluetoothDeviceButton({required this.device});

  @override
  _BluetoothDeviceButtonState createState() => _BluetoothDeviceButtonState();
}

class _BluetoothDeviceButtonState extends State<BluetoothDeviceButton> {
  late StreamSubscription<BluetoothConnectionState> _connectionSubscription;
  Map<String, StreamSubscription<List<int>>> _dataSubscriptions = {};
// Map<String, StreamSubscription<List<int>>> _dataSubscriptions = {};

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
            print('Received data from ${widget.device.remoteId}: $decodedString');
            // Process received data here
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _connectionSubscription =
        widget.device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        await _startReadingData();
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

// make sure it's uppercase
  Map<String, String> bluetoothMap = {
    'E8:6B:EA:D3:70:46': 'Front Left',
    'key3': 'unknown',
  };

  SensorName(String ID) {
    return getValueFromMapOrFallback(bluetoothMap, ID, 'key3');
  }

  displaySensor(String SensorName) {
    return SensorName != 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return displaySensor(SensorName(widget.device.remoteId.toString()))
        ? GestureDetector(
            onTap: () async {
              if (widget.device.isConnected) {
                await widget.device.disconnect();
                Fluttertoast.showToast(
                  msg: "${widget.device.remoteId} disconnected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color(0xFFFBFFFE),
                  textColor: Color(0xff1B1B1E),
                  fontSize: 16.0,
                );
              } else {
                await widget.device.connect();
                Fluttertoast.showToast(
                  msg: "${widget.device.remoteId} connected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Color(0xFFFBFFFE),
                  textColor: Color(0xff1B1B1E),
                  fontSize: 16.0,
                );
              }
            },
            child: Container(
              height: 80,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: !widget.device.isConnected
                    ? const Color(0xFF96031A)
                    : const Color(0xFFFBFFFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  title: Text(
                    // widget.device.servicesList.ch?
                    // widget.device.remoteId.toString(),
                    SensorName(widget.device.remoteId.toString()),
                    style: TextStyle(
                      color: !widget.device.isConnected
                          ? Color(0xFFFBFFFE)
                          : Color(0xff1B1B1E),
                    ),
                  ),
                  subtitle: Text(
                    !widget.device.isConnected ? "disconnected" : "connected",
                    style: TextStyle(
                      color: !widget.device.isConnected
                          ? Color(0xFFFBFFFE)
                          : Color(0xff1B1B1E),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
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
