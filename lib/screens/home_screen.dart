import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:objectdetectorapp/main.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isWorking = false;
  CameraController _cameraController;
  CameraImage _cameraImage;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    _cameraController?.dispose();
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224.tflite',
      labels: 'assets/mobilenet_v1_1.0_224.txt',
    );
  }

  Future<void> _runModelOnStreamFrames() async {
    if (_cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: _cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageWidth: _cameraImage.width,
        imageHeight: _cameraImage.height,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      _result = '';
      recognitions.forEach((response) {
        _result += response['label'] +
            '   ' +
            (response['confidence'] as double).toStringAsFixed(2) +
            '\n\n';
      });

      setState(() {
        _result;
      });

      _isWorking = false;
    }
  }

  void _initCamera() {
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    _cameraController.initialize().then((value) {
      if (!mounted)
        return;
      else {
        setState(() {
          _cameraController.startImageStream((imageFromStream) {
            if (!_isWorking) {
              _isWorking = true;
              _cameraImage = imageFromStream;
              _runModelOnStreamFrames();
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/jarvis.jpg'),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: 320.0,
                        child: Image.asset('assets/images/camera.jpg'),
                      ),
                    ),
                    Center(
                      child: FlatButton(
                        onPressed: _initCamera,
                        child: Container(
                          margin: EdgeInsets.only(top: 35.0),
                          width: 360.0,
                          height: 270.0,
                          child: _cameraImage == null
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 270.0,
                                  child: Icon(
                                    Icons.photo_camera_front,
                                    color: Colors.blueAccent,
                                    size: 40.0,
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio:
                                      _cameraController.value.aspectRatio,
                                  child: CameraPreview(_cameraController),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: TextStyle(
                          backgroundColor: Colors.black87,
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
