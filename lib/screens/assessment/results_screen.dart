// lib/screens/assessment/results_screen.dart
import 'package:flutter/material.dart' hide Badge;
import 'package:talent_assessment/core/models/badge.dart';
import 'package:talent_assessment/core/models/test_result.dart';
import 'package:talent_assessment/core/services/badge_service.dart';
import 'package:talent_assessment/core/services/cheat_detection_service.dart';
import 'package:talent_assessment/core/services/data_service.dart';
import 'package:talent_assessment/core/services/pose_analysis_service.dart';

class EnhancedResultsScreen extends StatefulWidget {
  final String testType;
  final CheatDetectionResult cheatResult;
  final PoseAnalysisResult poseResult;

  const EnhancedResultsScreen({
    super.key,
    required this.testType,
    required this.cheatResult,
    required this.poseResult,
  });

  @override
  State<EnhancedResultsScreen> createState() => _EnhancedResultsScreenState();
}

class _EnhancedResultsScreenState extends State<EnhancedResultsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.cheatResult.isValid && widget.poseResult.isValid) {
      _saveResult();
    }
  }

  Future<void> _saveResult() async {
    final result = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testType: widget.testType,
      repCount: widget.poseResult.repCount,
      timestamp: DateTime.now(),
    );
    await DataService.instance.saveTestResult(result);

    final allResults = await DataService.instance.getLocalTestResults();
    final newBadges =
        await BadgeService.instance.checkNewBadges(result, allResults);

    if (newBadges.isNotEmpty && mounted) {
      _showBadgeDialog(newBadges);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverallValid =
        widget.cheatResult.isValid && widget.poseResult.isValid;
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Results')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildScoreCard(isOverallValid),
          const SizedBox(height: 16),
          _buildAnalysisCard('Authenticity', widget.cheatResult.isValid, [
            _buildAnalysisRow('Confidence',
                '${(widget.cheatResult.confidence * 100).toInt()}%'),
          ]),
          const SizedBox(height: 16),
          _buildAnalysisCard('Form Quality', widget.poseResult.isValid, [
            _buildAnalysisRow('Overall Form',
                '${(widget.poseResult.formQuality * 100).toInt()}%'),
            _buildAnalysisRow('Rep Count', '${widget.poseResult.repCount}'),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(bool isValid) {
    return Card(
      elevation: 4,
      color: isValid ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              widget.testType.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.poseResult.repCount} reps',
              style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isValid ? 'VALID ASSESSMENT' : 'ASSESSMENT INVALID',
                style: TextStyle(
                  color: isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String title, bool isValid, List<Widget> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(isValid ? Icons.check_circle : Icons.cancel,
                    color: isValid ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(isValid ? 'Pass' : 'Fail',
                    style: TextStyle(
                        color: isValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showBadgeDialog(List<Badge> newBadges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Achievement Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newBadges
              .map((badge) => ListTile(
                    leading:
                        Text(badge.icon, style: const TextStyle(fontSize: 30)),
                    title: Text(badge.name),
                    subtitle: Text(badge.description),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}
