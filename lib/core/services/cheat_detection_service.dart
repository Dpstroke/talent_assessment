// lib/core/services/cheat_detection_service.dart
import 'dart:math';

class CheatDetectionService {
  static final CheatDetectionService instance = CheatDetectionService._init();
  CheatDetectionService._init();

  Future<CheatDetectionResult> validateVideo(String videoPath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    // Simulate a 90% chance of a valid result
    bool isValid = random.nextDouble() > 0.1;

    return CheatDetectionResult(
      isValid: isValid,
      confidence: isValid
          ? 0.85 + random.nextDouble() * 0.14
          : 0.4 + random.nextDouble() * 0.3,
      warnings: isValid
          ? []
          : ['Unstable camera detected', 'Inconsistent movement speed'],
    );
  }
}

class CheatDetectionResult {
  final bool isValid;
  final double confidence;
  final List<String> warnings;

  CheatDetectionResult({
    required this.isValid,
    required this.confidence,
    required this.warnings,
  });
}
