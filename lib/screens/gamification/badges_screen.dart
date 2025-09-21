// lib/screens/gamification/badges_screen.dart
import 'package:flutter/material.dart' hide Badge;
import 'package:talent_assessment/core/models/badge.dart';
import 'package:talent_assessment/core/services/badge_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  late Future<List<Badge>> _badgesFuture;

  @override
  void initState() {
    super.initState();
    _badgesFuture = BadgeService.instance.getAllBadges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Badges')),
      body: FutureBuilder<List<Badge>>(
        future: _badgesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load badges.'));
          }
          final badges = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) => _buildBadgeCard(badges[index]),
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Card(
      elevation: badge.unlocked ? 4 : 1,
      color: badge.unlocked ? Colors.white : Colors.grey[200],
      child: Opacity(
        opacity: badge.unlocked ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                badge.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
