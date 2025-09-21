import 'dart:math';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SitUpCounter {
  int reps = 0;
  String _state = 'down';

  int countReps(List<Pose> poses) {
    reps = 0;
    _state = 'down';

    for (final pose in poses) {
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

      if (leftHip != null && leftShoulder != null && leftKnee != null) {
        final angle = _getAngle(leftShoulder, leftHip, leftKnee);

        // ADD THIS LINE TO DEBUG
        debugPrint(
            'Current State: $_state, Calculated Angle: ${angle.toStringAsFixed(2)}');

        if (_state == 'down' && angle < 140) {
          // Now 135 will trigger the "up" state
          _state = 'up';
        } else if (_state == 'up' && angle > 170) {
          // Now 180 will trigger the "down" state
          _state = 'down';
          reps++;
        }
      }
    }
    return reps;
  }

  double _getAngle(
      PoseLandmark first, PoseLandmark second, PoseLandmark third) {
    final radians = atan2(third.y - second.y, third.x - second.x) -
        atan2(first.y - second.y, first.x - second.x);
    double angle = (radians * 180.0 / pi).abs();
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }
}
