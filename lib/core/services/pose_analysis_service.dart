import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:talent_assessment/core/analysis/rep_counter.dart';

class PoseAnalysisService {
  static final PoseAnalysisService instance = PoseAnalysisService._init();
  PoseAnalysisService._init();

  Future<PoseAnalysisResult> analyzeMovement(
      String videoPath, String testType) async {
    await Future.delayed(const Duration(seconds: 1));

    int repCount = 0;
    double formQuality = 0.85 + Random().nextDouble() * 0.14;

    if (testType == 'situps') {
      // 1. Generate a fake list of poses that simulates a sit-up motion
      final mockPoses = _generateMockSitUpPoses(reps: 5);

      // 2. Use our SitUpCounter to count the reps from the mock data
      repCount = SitUpCounter().countReps(mockPoses);

      debugPrint(
          "SitUpCounter processed mock data and counted: $repCount reps");
    } else {
      // For other exercises, we'll still use random data for now
      repCount = 10 + Random().nextInt(30);
    }

    return PoseAnalysisResult(
      repCount: repCount,
      formQuality: formQuality,
      isValid: formQuality > 0.65,
    );
  }

  // CORRECTED: This mock data now simulates proper angle changes
  List<Pose> _generateMockSitUpPoses({required int reps}) {
    final List<Pose> poses = [];
    for (int i = 0; i < reps; i++) {
      // Simulate "down" position (angle ~180 degrees)
      poses.add(Pose(landmarks: {
        PoseLandmarkType.leftShoulder: PoseLandmark(
            type: PoseLandmarkType.leftShoulder,
            x: 100,
            y: 100,
            z: 0,
            likelihood: 1.0),
        PoseLandmarkType.leftHip: PoseLandmark(
            type: PoseLandmarkType.leftHip,
            x: 100,
            y: 200,
            z: 0,
            likelihood: 1.0),
        PoseLandmarkType.leftKnee: PoseLandmark(
            type: PoseLandmarkType.leftKnee,
            x: 100,
            y: 300,
            z: 0,
            likelihood: 1.0),
      }));
      // Simulate "up" position (angle < 100 degrees)
      poses.add(Pose(landmarks: {
        PoseLandmarkType.leftShoulder: PoseLandmark(
            type: PoseLandmarkType.leftShoulder,
            x: 150,
            y: 150,
            z: 0,
            likelihood: 1.0),
        PoseLandmarkType.leftHip: PoseLandmark(
            type: PoseLandmarkType.leftHip,
            x: 100,
            y: 200,
            z: 0,
            likelihood: 1.0),
        PoseLandmarkType.leftKnee: PoseLandmark(
            type: PoseLandmarkType.leftKnee,
            x: 100,
            y: 300,
            z: 0,
            likelihood: 1.0),
      }));
    }
    // Add one final "down" position to complete the last rep
    poses.add(Pose(landmarks: {
      PoseLandmarkType.leftShoulder: PoseLandmark(
          type: PoseLandmarkType.leftShoulder,
          x: 100,
          y: 100,
          z: 0,
          likelihood: 1.0),
      PoseLandmarkType.leftHip: PoseLandmark(
          type: PoseLandmarkType.leftHip,
          x: 100,
          y: 200,
          z: 0,
          likelihood: 1.0),
      PoseLandmarkType.leftKnee: PoseLandmark(
          type: PoseLandmarkType.leftKnee,
          x: 100,
          y: 300,
          z: 0,
          likelihood: 1.0),
    }));
    return poses;
  }

  // We keep this method for when we fix the camera plugin
  Future<void> processImage(InputImage inputImage) async {
    final poseDetector = PoseDetector(options: PoseDetectorOptions());
    try {
      final List<Pose> poses = await poseDetector.processImage(inputImage);
      if (poses.isEmpty) {
        debugPrint("No poses detected in the image.");
        return;
      }
      for (final pose in poses) {
        pose.landmarks.forEach((landmarkType, landmark) {
          debugPrint(
              'LANDMARK: ${landmarkType.name}, x: ${landmark.x.toStringAsFixed(2)}, y: ${landmark.y.toStringAsFixed(2)}');
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      poseDetector.close();
    }
  }
}

class PoseAnalysisResult {
  final int repCount;
  final double formQuality;
  final bool isValid;

  PoseAnalysisResult({
    required this.repCount,
    required this.formQuality,
    required this.isValid,
  });
}
