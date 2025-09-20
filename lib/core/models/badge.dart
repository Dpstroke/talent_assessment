// lib/core/models/badge.dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedDate;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedDate,
  });
}
