import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_assessment/core/services/auth_service.dart';
import 'package:talent_assessment/core/services/data_service.dart';
import 'package:talent_assessment/screens/assessment/test_selection_screen.dart';
import 'package:talent_assessment/screens/gamification/badges_screen.dart';
import 'package:talent_assessment/screens/leaderboard/leaderboard_screen.dart';
import 'package:talent_assessment/screens/profile/profile_screen.dart';
import 'package:talent_assessment/widgets/stat_card.dart';

// This is the main widget that holds the Bottom Navigation Bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTabScreen(),
    const TestSelectionScreen(),
    const LeaderboardScreen(),
    const BadgesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_circle), label: 'Tests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Rankings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Badges'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// This is the enhanced dashboard widget for the "Home" tab
class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showStats = true);
      }
    });
  }

  Future<void> _loadStats() async {
    final stats = await DataService.instance.getUserStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('Welcome back,',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    user?.email?.split('@').first ?? 'Athlete',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildChallengeCard(),
                  const SizedBox(height: 24),
                  Text('Your Progress',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showStats ? 1.0 : 0.0,
                    child: _buildStatsRow(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChallengeCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ready for your next challenge?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Push your limits and climb the leaderboard.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Start New Assessment'),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: This now uses the new reusable StatCard widget
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Tests',
            value: '${_stats['totalTests'] ?? 0}',
            icon: Icons.assessment,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'This Week',
            value: '${_stats['thisWeek'] ?? 0}',
            icon: Icons.calendar_today,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
