import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_assessment/core/models/test_result.dart';
import 'package:talent_assessment/core/services/auth_service.dart';
import 'package:talent_assessment/core/services/data_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _stats = {};
  List<TestResult> _recentTests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await DataService.instance.getUserStats();
    final tests = await DataService.instance.getLocalTestResults();

    if (mounted) {
      setState(() {
        _stats = stats;
        _recentTests = tests.reversed.take(5).toList();
        _isLoading = false;
      });
    }
  }

  // ADDED LOGOUT DIALOG METHOD
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog, // UPDATED to call the dialog
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildStatsCards(),
                  const SizedBox(height: 20),
                  _buildRecentTests(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfo() {
    final user = Provider.of<AuthService>(context).user;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Text(user?.email ?? 'Athlete',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Tests', '${_stats['totalTests'] ?? 0}'),
            _buildStatItem('This Week', '${_stats['thisWeek'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentTests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_recentTests.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No tests completed yet.'),
              ))
            else
              ..._recentTests.map((test) => ListTile(
                    leading:
                        const Icon(Icons.fitness_center, color: Colors.blue),
                    title: Text(
                        '${test.testType[0].toUpperCase()}${test.testType.substring(1)} Test'),
                    subtitle: Text(
                        '${test.timestamp.day}/${test.timestamp.month}/${test.timestamp.year}'),
                    trailing: Text('${test.repCount} reps',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
          ],
        ),
      ),
    );
  }
}
