// lib/screens/leaderboard/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A simple model for leaderboard entries
class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;

  LeaderboardEntry(
      {required this.userId, required this.name, required this.score});

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unknown User',
      score: map['score']?.toInt() ?? 0,
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedTest = 'situps';
  Future<List<LeaderboardEntry>>? _leaderboardFuture;
  int? _userRank;
  LeaderboardEntry? _userEntry;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    setState(() {
      _leaderboardFuture = _fetchLeaderboard(_selectedTest);
    });
  }

  Future<List<LeaderboardEntry>> _fetchLeaderboard(String testType) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(testType)
        .get();

    if (!snapshot.exists || snapshot.data()?['rankings'] == null) {
      // Return sample data if Firestore is empty
      return [
        LeaderboardEntry(userId: '1', name: 'Alex Runner', score: 45),
        LeaderboardEntry(userId: '2', name: 'Sarah Strong', score: 42),
        LeaderboardEntry(userId: '3', name: 'Mike Power', score: 40),
      ];
    }

    final rankingsData =
        List<Map<String, dynamic>>.from(snapshot.data()!['rankings']);
    final entries =
        rankingsData.map((data) => LeaderboardEntry.fromMap(data)).toList();

    // Find current user's rank
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userIndex =
          entries.indexWhere((entry) => entry.userId == currentUser.uid);
      if (userIndex != -1) {
        _userRank = userIndex + 1;
        _userEntry = entries[userIndex];
      } else {
        _userRank = null;
        _userEntry = null;
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Column(
        children: [
          _buildTestSelector(),
          if (_userRank != null) _buildUserRankCard(),
          Expanded(child: _buildLeaderboardList()),
        ],
      ),
    );
  }

  Widget _buildTestSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTest,
        decoration: const InputDecoration(
          labelText: 'Select Test',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'situps', child: Text('Sit-ups')),
          DropdownMenuItem(value: 'pushups', child: Text('Push-ups')),
          DropdownMenuItem(value: 'jump', child: Text('Vertical Jump')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedTest = value;
              _loadLeaderboard();
            });
          }
        },
      ),
    );
  }

  Widget _buildUserRankCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
      child: ListTile(
        // <-- Remove 'const'
        leading: Text('#$_userRank',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor)),
        title: const Text('Your Rank',
            style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('${_userEntry?.score ?? 0} reps',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No leaderboard data available.'));
        }

        final entries = snapshot.data!;
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rank = index + 1;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRankColor(rank),
                child: Text('$rank',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(entry.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text('${entry.score}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[400]!;
    return Theme.of(context).primaryColor;
  }
}
