// lib/core/models/test_result.dart
class TestResult {
  final String id;
  final String testType;
  final int repCount;
  final DateTime timestamp;
  final bool isValid;

  TestResult({
    required this.id,
    required this.testType,
    required this.repCount,
    required this.timestamp,
    this.isValid = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testType': testType,
      'repCount': repCount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isValid': isValid,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'],
      testType: map['testType'],
      repCount: map['repCount'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isValid: map['isValid'] ?? true,
    );
  }
}
