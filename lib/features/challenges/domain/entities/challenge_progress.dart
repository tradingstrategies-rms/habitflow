import 'package:flutter/foundation.dart';

@immutable
class ChallengeProgress {
  final String challengeId;
  final String profileId;
  final double currentValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastUpdatedAt;
  final DateTime periodStartDate;

  const ChallengeProgress({
    required this.challengeId,
    required this.profileId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.lastUpdatedAt,
    required this.periodStartDate,
  });

  ChallengeProgress copyWith({
    double? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? lastUpdatedAt,
    DateTime? periodStartDate,
  }) {
    return ChallengeProgress(
      challengeId: challengeId,
      profileId: profileId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      periodStartDate: periodStartDate ?? this.periodStartDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeProgress &&
          challengeId == other.challengeId &&
          profileId == other.profileId &&
          periodStartDate == other.periodStartDate);

  @override
  int get hashCode => 
      challengeId.hashCode ^ 
      profileId.hashCode ^ 
      periodStartDate.hashCode;
}
