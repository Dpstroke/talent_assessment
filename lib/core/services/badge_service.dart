// lib/core/services/badge_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_assessment/core/models/badge.dart';
import 'package:talent_assessment/core/models/test_result.dart';

class BadgeService {
  static final BadgeService instance = BadgeService._init();
  BadgeService._init();

  Future<List<Badge>> getAllBadges() async {
    final defaultBadges = _getDefaultBadges();
    final unlockedBadges = await _getUnlockedBadges();

    return defaultBadges.map((badge) {
      final isUnlocked = unlockedBadges.containsKey(badge.id);
      return Badge(
        id: badge.id,
        name: badge.name,
        description: badge.description,
        icon: badge.icon,
        unlocked: isUnlocked,
        unlockedDate: isUnlocked ? unlockedBadges[badge.id] : null,
      );
    }).toList();
  }

  Future<List<Badge>> checkNewBadges(
      TestResult newResult, List<TestResult> allResults) async {
    final newBadges = <Badge>[];
    final unlockedBadges = await _getUnlockedBadges();

    // Badge: First Test
    if (!unlockedBadges.containsKey('first_test') && allResults.isNotEmpty) {
      final badge = await _unlockBadge('first_test');
      newBadges.add(badge);
    }

    // Badge: Strong Performer (30+ reps)
    if (!unlockedBadges.containsKey('strong_performer') &&
        newResult.repCount >= 30) {
      final badge = await _unlockBadge('strong_performer');
      newBadges.add(badge);
    }

    // Badge: Consistent Athlete (3 tests in a week)
    final recentTests = allResults
        .where((r) => DateTime.now().difference(r.timestamp).inDays <= 7)
        .length;
    if (!unlockedBadges.containsKey('consistent') && recentTests >= 3) {
      final badge = await _unlockBadge('consistent');
      newBadges.add(badge);
    }

    return newBadges;
  }

  Future<Badge> _unlockBadge(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await _getUnlockedBadges();
    final badge = _getDefaultBadges().firstWhere((b) => b.id == id);

    unlocked[id] = DateTime.now();

    final newUnlockedMap =
        unlocked.map((key, value) => MapEntry(key, value.toIso8601String()));
    await prefs.setString('unlocked_badges', json.encode(newUnlockedMap));

    return badge;
  }

  Future<Map<String, DateTime>> _getUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('unlocked_badges') ?? '{}';
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, DateTime.parse(value)));
  }

  List<Badge> _getDefaultBadges() {
    return [
      Badge(
          id: 'first_test',
          name: 'First Steps',
          description: 'Complete your first test',
          icon: '🎯'),
      Badge(
          id: 'strong_performer',
          name: 'Strong Performer',
          description: 'Achieve 30+ reps in a test',
          icon: '💪'),
      Badge(
          id: 'consistent',
          name: 'Consistent Athlete',
          description: 'Complete 3 tests in one week',
          icon: '🔥'),
      Badge(
          id: 'perfectionist',
          name: 'Perfectionist',
          description: 'Achieve 50+ reps in any test',
          icon: '⭐'),
    ];
  }
}
