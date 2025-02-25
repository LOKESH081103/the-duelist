import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FaceRecognitionPage extends StatefulWidget {
  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _processAttendance() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _resultMessage = '';
    });

    try {
      // Capture image
      final image = await _controller!.takePicture();

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:5000/process-attendance'),
      );

      // Add image file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      if (result['success']) {
        setState(() {
          _resultMessage = result['recognized']
              ? 'Welcome, ${result['name']}!\nAttendance logged successfully.'
              : 'Face not recognized. Please try again.';
        });
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          if (_resultMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                _resultMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: _resultMessage.contains('Error')
                      ? Colors.red
                      : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processAttendance,
              child: _isProcessing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Take Attendance'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
