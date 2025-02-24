import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class TeacherHomePage extends StatefulWidget {
  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool isCameraInitialized = false;
  bool isBackCamera = true;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    await Permission.camera.request();
    cameras = await availableCameras();
    controller = CameraController(
      cameras[isBackCamera ? 0 : 1],
      ResolutionPreset.high,
    );
    await controller!.initialize();
    if (mounted) {
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  Future<void> toggleCamera() async {
    if (controller != null) {
      final CameraController oldController = controller!;
      controller = null;
      await oldController.dispose();
    }

    final CameraController newController = CameraController(
      cameras[isBackCamera ? 1 : 0],
      ResolutionPreset.high,
    );

    try {
      await newController.initialize();
      if (mounted) {
        setState(() {
          controller = newController;
          isBackCamera = !isBackCamera;
        });
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              if (isCameraInitialized) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      cameras: cameras,
                      initialCamera: isBackCamera ? 0 : 1,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Teacher Dashboard Content'),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int initialCamera;

  const CameraScreen({
    Key? key,
    required this.cameras,
    required this.initialCamera,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;
  int _currentCamera = 0;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.initialCamera;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final CameraController cameraController = CameraController(
      widget.cameras[_currentCamera],
      ResolutionPreset.high,
    );

    try {
      await cameraController.initialize();
      if (mounted) {
        setState(() {
          _controller = cameraController;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isInitialized = false;
    });

    final CameraController oldController = _controller;
    await oldController.dispose();

    _currentCamera = (_currentCamera + 1) % widget.cameras.length;
    await _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(_controller),
          ),

          // Controls Overlay
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Capture Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        final image = await _controller.takePicture();
                        print('Picture saved to ${image.path}');
                      } catch (e) {
                        print('Error taking picture: $e');
                      }
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        margin: EdgeInsets.all(5),
                      ),
                    ),
                  ),

                  // Switch Camera Button
                  IconButton(
                    icon: Icon(Icons.switch_camera,
                        color: Colors.white, size: 30),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
