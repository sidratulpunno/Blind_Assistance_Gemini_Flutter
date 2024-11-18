import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart'; // For capturing photos with camera and using XFile
import 'voice_command_service.dart';
import 'camera_service.dart';
import 'google_generative_ai_service.dart';
import 'tts_service.dart';
import 'package:gemini/app_state.dart';

void main() async {
  runApp(MyApp());


}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> {

  late VoiceCommandService _voiceCommandService;
  late CameraService _cameraService;
  late GoogleGenerativeAIService _aiService;
  late TTSService _ttsService;


  String _responseText = "Please tap Start Listening and say Give direction to get direction and say describe to get description";

  @override
  void initState() {
    super.initState();

    const apiKey = 'AIzaSyDVv-N-9eGyUoKHFzhTMQSfJCegYtgZE5M';
    _voiceCommandService = VoiceCommandService();
    _cameraService = CameraService();
    _aiService = GoogleGenerativeAIService(apiKey: apiKey);
    _ttsService = TTSService();
    _ttsService.speak(_responseText);

    _voiceCommandService.startListening(_onVoiceCommand);
    _cameraService.initializeCamera();
  }

  void _onVoiceCommand(String command) async {
    if (command.toLowerCase().contains("give direction")) {
      await _captureAndProcessPhoto();
      AppState.prompt=1;
    }else if (command.toLowerCase().contains("describe")) {
      await _captureAndProcessPhoto();
      AppState.prompt=2;
    }
  }

  Future<void> _captureAndProcessPhoto() async {

    XFile image = await _cameraService.capturePhoto();

    // Analyze image and get response
    String response = await _aiService.analyzeImage(image);

    setState(() {
      _responseText = response;
    });

    await _ttsService.speak(response);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Blind Assistance App",style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold),)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0), // Add some padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Make the response text scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(8.0), // Padding around the text
                    child: Text(
                      _responseText,

                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Spacing between text and buttons
              ElevatedButton(
                onPressed: () => _voiceCommandService.startListening(_onVoiceCommand),
                child: Text("Start Listening"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AppState.prompt = 1;
                  _captureAndProcessPhoto();
                },
                child: Text("Give Direction"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AppState.prompt = 2;
                  _captureAndProcessPhoto();
                },
                child: Text("Describe"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
