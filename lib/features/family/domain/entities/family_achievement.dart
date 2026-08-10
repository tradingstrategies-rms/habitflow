import 'package:flutter/foundation.dart';

@immutable
class FamilyAchievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final double targetValue;
  final double currentValue;
  final DateTime? unlockedAt;
  final String category;

  const FamilyAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.targetValue,
    this.currentValue = 0,
    this.unlockedAt,
    required this.category,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  FamilyAchievement copyWith({
    double? currentValue,
    DateTime? unlockedAt,
  }) {
    return FamilyAchievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyAchievement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currentValue == other.currentValue &&
          unlockedAt == other.unlockedAt);

  @override
  int get hashCode => id.hashCode ^ currentValue.hashCode ^ unlockedAt.hashCode;
}
