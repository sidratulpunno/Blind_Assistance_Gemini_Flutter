import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; // This won't work on the web
import 'package:path/path.dart';
import 'dart:io'; // Avoid this for web

class CameraService {
  CameraController? _controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.low);
    await _controller!.initialize();
  }

  Future<XFile> capturePhoto() async {
    final image = await _controller!.takePicture();
    return image; // Return XFile
  }
}
