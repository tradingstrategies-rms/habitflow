import 'package:flutter/foundation.dart';
import '../enums/challenge_type.dart';
import '../enums/challenge_difficulty.dart';

@immutable
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final double targetValue;
  final String unit;
  final int pointReward;
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  final String? relatedId; // e.g. habitId, goalId
  final List<String> eligibleProfileIds; // Empty list means all
  final bool isRecurring;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetValue,
    required this.unit,
    required this.pointReward,
    required this.xpReward,
    required this.startDate,
    required this.endDate,
    this.relatedId,
    this.eligibleProfileIds = const [],
    this.isRecurring = false,
  });

  bool get isExpired => !isRecurring && DateTime.now().isAfter(endDate);
  bool get isActive => DateTime.now().isAfter(startDate) && (isRecurring || !isExpired);

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    double? targetValue,
    String? unit,
    int? pointReward,
    int? xpReward,
    DateTime? startDate,
    DateTime? endDate,
    String? relatedId,
    List<String>? eligibleProfileIds,
    bool? isRecurring,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      pointReward: pointReward ?? this.pointReward,
      xpReward: xpReward ?? this.xpReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      relatedId: relatedId ?? this.relatedId,
      eligibleProfileIds: eligibleProfileIds ?? this.eligibleProfileIds,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
