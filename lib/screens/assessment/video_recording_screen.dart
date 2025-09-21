// lib/screens/assessment/video_recording_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:talent_assessment/core/services/cheat_detection_service.dart';
import 'package:talent_assessment/core/services/pose_analysis_service.dart';
import 'package:talent_assessment/screens/assessment/results_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  final String testType;
  const VideoRecordingScreen({super.key, required this.testType});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.high,
        enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _stopRecordingAndProcess() async {
    if (!_isInitialized || _controller == null) return;

    final file = await _controller!.stopVideoRecording();
    setState(() => _isRecording = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Analyzing video..."),
            ],
          ),
        ),
      ),
    );

    // Using the SIMULATED services for now
    final cheatResult =
        await CheatDetectionService.instance.validateVideo(file.path);
    final poseResult = await PoseAnalysisService.instance
        .analyzeMovement(file.path, widget.testType);

    if (!mounted) return;
    Navigator.pop(context); // Close the processing dialog

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedResultsScreen(
          testType: widget.testType,
          cheatResult: cheatResult,
          poseResult: poseResult,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _controller == null) return;
    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller!)),
                _buildControls(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: FloatingActionButton(
          backgroundColor: _isRecording ? Colors.white : Colors.red,
          onPressed: _isRecording ? _stopRecordingAndProcess : _startRecording,
          child: Icon(
            _isRecording ? Icons.stop : Icons.fiber_manual_record,
            color: _isRecording ? Colors.red : Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
