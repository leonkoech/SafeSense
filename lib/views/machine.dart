import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionWidget extends StatefulWidget {
  @override
  _PredictionWidgetState createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  List<double> _output = [];

  @override
  void initState() {
    super.initState();
    print("initalizng model ----->>>>>>");
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/MHW.tflite');
      setState(() {
        _isModelLoaded = true;
      });

      printModelDetails();
    } catch (e) {
      print('Failed to load the model: $e');
    }
  }

  void printModelDetails() {
    var inputTensor = _interpreter.getInputTensor(0);
    var outputTensor = _interpreter.getOutputTensor(0);

    print('Inout tensor shape ${inputTensor.shape} Type: ${inputTensor.type}');
    print(
        'output tensor shape ${outputTensor.shape} Type: ${outputTensor.type}');
  }

  void predict() {
    if (!_isModelLoaded || _interpreter == null) {
      print('Model not loaded yet');
      return;
    }

    List<double> inputData = [
      50, 55, 45, 2.0, 2.5, 1.8, 2.0, // Your input data
    ];
    // var outputData = List.generate(1, (index) => List.filled(8, 0.0));
    var outputData = [
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    ];

    // Assume the output is a single float value
    // List<double> outputData = List.filled(8, 0);

    print("interpreter initilaixe andkfasbdkfasbdfkasdf sdf ${outputData}");
    // _interpreter.runInference(inputs)
    _interpreter.run(inputData, outputData);
    print("this part");
    print(outputData.first);
    print(outputData);
    setState(() {
      _output = outputData.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predictive Model'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                print("calling button funccition");
                predict();
              },
              child: Text(_isModelLoaded ? 'Predict' : 'not loaded '),
            ),
            // Text(
            //     'Output: ${_output.isNotEmpty ? _output.first.toString() : "No prediction"}'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
