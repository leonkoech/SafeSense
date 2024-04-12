import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_aid/components/CarBorder.dart';

import 'package:flutter/widgets.dart';
import 'package:swipe_aid/views/audio.dart';
import 'package:swipe_aid/views/collision.dart';
import 'package:geolocator/geolocator.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:swipe_aid/views/machine.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

Map<String, String> bluetoothMap = {
  'E8:6B:EA:D3:70:46': 'Front Left',
  'E8:6B:EA:D4:01:EA': 'Front Right',
  'EC:64:C9:86:62:02': 'Back Left',
  'A0:A3:B3:FE:FB:56': 'Back Right', //a0:a3:b3:fe:fb:56

  'key3': 'unknown',
};

SensorName(String ID) {
  return getValueFromMapOrFallback(bluetoothMap, ID, 'key3');
}

displaySensor(String SensorName) {
  return SensorName != 'unknown';
}

final sensorData = ValueNotifier<Map<String, Map<String, dynamic>>>({
  "Front Left": {
    "triggered": false,
    "value": 0.0,
    "trigger_time": DateTime.now().millisecondsSinceEpoch
  },
  "Back Left": {
    "triggered": false,
    "value": 0.0,
    "trigger_time": DateTime.now().millisecondsSinceEpoch
  },
  "Front Right": {
    "triggered": false,
    "value": 0.0,
    "trigger_time": DateTime.now().millisecondsSinceEpoch
  },
  "Back Right": {
    "triggered": false,
    "value": 0.0,
    "trigger_time": DateTime.now().millisecondsSinceEpoch
  },
  "unknown": {
    "triggered": false,
    "value": 0.0,
    "trigger_time": DateTime.now().millisecondsSinceEpoch
  },
});

final playAlert = ValueNotifier<bool>(false);

// final audioPlayer = AudioPlayer();

// void _playProximityAudio() async {
//   bool is_too_close = false;
//   bool is_close = false;

//   sensorData.forEach((key, value) async {
//     if (value > 0.0 && value <= 0.5) {
//       is_too_close = true;
//     } else if (value < 1.0) {
//       is_close = true;
//     }
//   });

//   void player_settings(double speed) async {
//     ReleaseMode loop = ReleaseMode.loop;
//     await audioPlayer.setPlaybackRate(speed); // half speed
//     await audioPlayer.setReleaseMode(loop);
//   }

//   if (is_too_close) {
//     audioPlayer.setSource(AssetSource('beep.wav'));
//     player_settings(1.0);
//   } else if (is_close) {
//     audioPlayer.setSource(AssetSource('beep.wav'));
//     player_settings(2.0);
//   } else {
//     // stop the player
//     await audioPlayer.stop();
//   }
// }

Map<String, double> car_speeds = {
  "Right": 0.0,
  "Left": 0.0,
};
final current_speed = ValueNotifier<double>(0.0);

double calculateRelativeVelocity(
    double distanceBetweenSensors, int timeDifference, double currentSpeed) {
  // TODO change timeDifference to hours
  // TODO make sure distance is in miles per hour
  // TODO make sure the currrent speed is in miles per hour

  // length of a car in miles
  double length_of_car = distanceBetweenSensors;
  // difference in time in hours
  double difference_in_time = timeDifference / 3600000;
  // please ensure that current speed is in miles per hour
  double speed_of_current_car = currentSpeed;

  // speed of other car = (length/time) + speed of current car
  //

  double speed_of_neighboring_car =
      (length_of_car / difference_in_time) + speed_of_current_car;

  return speed_of_neighboring_car;
}

void automaticConnect(BluetoothDevice device) {
  if (displaySensor(SensorName(device.remoteId.toString()))) {
    device.connect();
    // print(device.remoteId.toString() + "connected");
  }
  // widget.device.connect()
}

class Sensors extends StatefulWidget {
  const Sensors({Key? key}) : super(key: key);

  @override
  _SensorsState createState() => _SensorsState();
}

class _SensorsState extends State<Sensors> {
  // final  = AudioPlayer();
  // late AudioPlayer audioPlayer = AudioPlayer();

  late AudioPlayer player = AudioPlayer();
  PlayerState? _playerState;
  bool get _isPlaying => _playerState == PlayerState.playing;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _startBluetoothScan();
    _initializeSoundPlayer();
    _initTriggerListener();
    _initAlertListener();
    _playerState = player.state;
    // _playProximityAudio();
  }

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();

    super.dispose();
  }
  // void _playProximityAudio() async {
  //   bool isTooClose = false;
  //   bool isClose = false;

  //   for (var entry in sensorData.entries) {
  //     var value = entry.value['value'];
  //     if (value > 0.0 && value <= 0.5) {
  //       isTooClose = true;
  //     } else if (value < 1.0) {
  //       isClose = true;
  //     }
  //   }

  //   await playerSettings(isTooClose
  //       ? 1.0
  //       : isClose
  //           ? 2.0
  //           : 0.0);
  //   if (isTooClose || isClose) {
  //     await audioPlayer.setSource(AssetSource('beep.mp3'));
  //     await audioPlayer.resume();
  //     print("audio started playing");
  //   } else {
  //     await audioPlayer.stop();
  //     print("audio stopped playing");
  //   }
  // }

  // Future<void> playerSettings(double speed) async {
  //   ReleaseMode loop = ReleaseMode.loop;
  //   await audioPlayer.setPlaybackRate(speed);
  //   await audioPlayer.setReleaseMode(loop);
  // }
// Function to be called on initialization to listen for changes
  void _initTriggerListener() {
    sensorData.addListener(() {
      // This function will be called whenever the value inside playerPointsToAdd changes
      Map<String, Map<String, dynamic>> sensorDataValues = sensorData.value;
      List<bool> trigger_accumulation = [false, false, false, false];
      List<String> trigger_indexes = [
        "Front Left",
        "Back Left",
        "Front Right",
        "Back Right"
      ];

      sensorDataValues.forEach((key, value) {
        // Accessing the values inside each sub-map
        if (key != "unknown") {
          bool triggered = value['triggered'];
          trigger_accumulation[trigger_indexes.indexOf(key)] = triggered;
        }
      });
      print(trigger_accumulation);

      playAlert.value = trigger_accumulation.contains(true);
    });
  }

  void _initAlertListener() {
    playAlert.addListener(() {
      print(('${playAlert.value} ---------------------------------- value'));
      if (playAlert.value == true) {
        _play();
      } else {
        // stop code
        _stop();
      }
    });
  }

  Future<void> _play() async {
    await player.setReleaseMode(ReleaseMode.loop);

    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _stop() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _initializeSoundPlayer() async {
    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    player.setVolume(1);
    // player

    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(
          UrlSource("https://www.soundjay.com/buttons/sounds/beep-01a.mp3"));
      await player.resume();
    });
    _initStreams();
  }

  void _initStreams() {
    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
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

  bool vehicleSelected = false;
  String imageOfVehicle = "car main.png";
  Map<String, String> vehicleMap = {
    "Sedan": "car main.png",
    "Coupe": "coupe.png",
    "Mini Van": "mini-van.png",
    "SUV": "suv.png",
  };

  double current_car_speed = 0.0;

  void _carSpeedListener() {
    current_speed.addListener(() {
      current_car_speed = current_speed.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> sensorData =
    //     SensorDataProvider.of(context)?._sensorData ?? {};
    return Scaffold(
        backgroundColor: Color(0xFF060607),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            vehicleSelected ? "Car Mode" : "Select Vehicle Type",
            style: TextStyle(color: Color(0xFFFBFFFE)),
          ),
        ),
        body: vehicleSelected
            ? BluetoothDeviceList(
                devices: devices,
                vehicleImgName: imageOfVehicle,
              )
            : ListView(
                children: vehicleMap.keys.map((key) {
                  return Container(
                    // height: 120,
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF363276),
                    ),
                    child: Center(
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            vehicleSelected = true;
                            imageOfVehicle = '${vehicleMap[key]}';
                          });
                        },
                        title: Center(
                            child: Text(key,
                                style: const TextStyle(
                                    color: Color(0xFFFBFFFE), fontSize: 16))),
                        trailing: Container(
                          width: 80, // adjust width as needed
                          height: 150, // adjust height as needed
                          child: Image.asset(
                            'assets/${vehicleMap[key]}', // assuming images are in the assets folder
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
        floatingActionButton: vehicleSelected
            ? Wrap(
                //will break to another line on overflow
                direction:
                    Axis.horizontal, //use vertical to show  on vertical axis
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        // Add your action here
                        setState(() {
                          vehicleSelected = false;
                        });
                      },
                      child: Icon(Icons.arrow_back), // You can change the icon
                      backgroundColor:
                          Colors.blue, // You can change the background color
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        for (BluetoothDevice device in devices) {
                          String sensorName =
                              SensorName(device.remoteId.toString());
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
                  ), //button first

                  Container(
                    margin: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        // Add your action here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // TODO remove const
                              builder: (context) =>  Collision(
                                    speed: current_car_speed,
                                    rightSpeed: current_car_speed - 20,
                                    leftSpeed: current_car_speed - 10,
                                    preventiveMeasure: "change lane",
                                    atFault: "other",
                                    sensorData: sensorData.value,
                                  )),
                        );
                      },
                      child: Icon(Icons.arrow_right), // You can change the icon
                      backgroundColor:
                          Colors.blue, // You can change the background color
                    ),
                  ), // button second// button second
                  Container(
                    margin: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        // _play();
                        _playerState == PlayerState.playing ? _stop() : _play();
                        // playAlert.value = true;
                      },
                      child: Icon(Icons.speaker), // You can change the icon
                      backgroundColor:
                          Colors.blue, // You can change the background color
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      onPressed: () {
                        // _play();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // TODO remove const
                              builder: (context) => PredictionWidget()),
                        );
                        // playAlert.value = true;
                      },
                      child: Icon(Icons.arrow_right), // You can change the icon
                      backgroundColor:
                          Colors.blue, // You can change the background color
                    ),
                  ),
                  // button third

                  // Add more buttons here
                ],
              )
            : const SizedBox());
  }
}

class BluetoothDeviceList extends StatefulWidget {
  final List<BluetoothDevice> devices;
  final String vehicleImgName;

  const BluetoothDeviceList(
      {super.key, required this.devices, required this.vehicleImgName});

  @override
  _BluetoothDeviceListState createState() => _BluetoothDeviceListState();
}

class _BluetoothDeviceListState extends State<BluetoothDeviceList> {
  final StreamController<double> _speedController = StreamController<double>();

  Stream<double> get speedStream => _speedController.stream;

  final LocationSettings locationSettings = const LocationSettings(
    // accuracy: LocationAccuracy.best,
    // TODO: testing
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
      current_speed.value = speedMph;
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
          padding: const EdgeInsets.only(top: 20, bottom: 20),
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
        Text(
          'Prevention Measure',
          style: TextStyle(color: Color(0xFFFBFFFE), fontSize: 20),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, bottom: 90),
            // height: MediaQuery.of(context).size.height-30,
            // alignment: Alignment.center,
            // color: Colors.red,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Stack(children: DevicesList()),
                  Image.asset(
                    'assets/${widget.vehicleImgName}',
                    // height: MediaQuery.of(context).size.height-30,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Map<String, Map<String, String>> split_sensor(String my_sensor) {
    var split_data = my_sensor.split(" ");
    print(split_data);
    return {
      "current": {"side": split_data[0], "direction": split_data[1]},
      "other": {
        "side": split_data[0] == "Front" ? "Back" : "Front",
        "direction": split_data[1]
      }
    };
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
            setState(() {
              // _distance = newDistance;
              distance = (parseDoubleSafely(decodedString) / 100);
            });
            // print('Received data from ${widget.device.remoteId}: $distance');
            // TODO: update the speed calculator

            // sensorData[SensorName(widget.device.remoteId.toString())]["value"] = (distance == 0.0)? null: distance;

            // Process received data here
            bool triggered = distance > 0.0 && distance < 1.1;
            String current_sensor_name =
                SensorName(widget.device.remoteId.toString());
            if (displaySensor(current_sensor_name)) {
              // Map<String, Map<String, String>> sensor_map =
              //     split_sensor(current_sensor_name);
              // String other_sensor_name =
              //     '${sensor_map!["other"]!["side"]}_${sensor_map["other"]!["direction"]}';

              Map<String, Map<String, dynamic>> sensorDataCpy =
                  Map<String, Map<String, dynamic>>.from(sensorData.value);

              sensorDataCpy[current_sensor_name]?["value"] = distance;
              sensorDataCpy[current_sensor_name]?["triggered"] = triggered;
              if (triggered) {
                // change the time only when it's triggered
                sensorDataCpy[current_sensor_name]?["trigger_time"] =
                    DateTime.now().microsecondsSinceEpoch;
              }

              sensorData.value = sensorDataCpy;
            }
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
      } else {
        automaticConnect(widget.device);
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

class SensorDataProvider extends StatefulWidget {
  final Widget child;
  final Map<String, dynamic> initialSensorData;

  const SensorDataProvider({
    Key? key,
    required this.child,
    required this.initialSensorData,
  }) : super(key: key);

  static _SensorDataProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SensorDataProviderState>();
  }

  @override
  _SensorDataProviderState createState() => _SensorDataProviderState();
}

class _SensorDataProviderState extends State<SensorDataProvider> {
  late Map<String, dynamic> _sensorData;

  @override
  void initState() {
    super.initState();
    _sensorData = widget.initialSensorData;
  }

  void updateSensorData(String key, dynamic newValue) {
    setState(() {
      _sensorData[key] = newValue;
    });
  }

  Map<String, dynamic> getSensorData() {
    return _sensorData;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
