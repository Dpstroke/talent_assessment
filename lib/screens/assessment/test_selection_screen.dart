// lib/screens/assessment/test_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:talent_assessment/screens/assessment/video_recording_screen.dart';

class TestSelectionScreen extends StatelessWidget {
  const TestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildTestCard(
                context, 'Sit-ups', Icons.accessibility_new, 'situps'),
            _buildTestCard(
                context, 'Push-ups', Icons.fitness_center, 'pushups'),
            _buildTestCard(
                context, 'Vertical Jump', Icons.arrow_upward, 'jump'),
            _buildTestCard(
                context, 'Shuttle Run', Icons.directions_run, 'shuttle'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
      BuildContext context, String title, IconData icon, String testType) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoRecordingScreen(testType: testType),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
