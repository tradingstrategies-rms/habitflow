import 'package:flutter/foundation.dart';

@immutable
class RewardAccount {
  final String profileId;
  final int points;
  final int experience;
  final int level;
  final int lifetimeEarnings;
  final DateTime lastUpdatedAt;

  const RewardAccount({
    required this.profileId,
    required this.points,
    required this.experience,
    required this.level,
    required this.lifetimeEarnings,
    required this.lastUpdatedAt,
  });

  RewardAccount copyWith({
    int? points,
    int? experience,
    int? level,
    int? lifetimeEarnings,
    DateTime? lastUpdatedAt,
  }) {
    return RewardAccount(
      profileId: profileId,
      points: points ?? this.points,
      experience: experience ?? this.experience,
      level: level ?? this.level,
      lifetimeEarnings: lifetimeEarnings ?? this.lifetimeEarnings,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardAccount &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          points == other.points &&
          experience == other.experience &&
          level == other.level &&
          lifetimeEarnings == other.lifetimeEarnings);

  @override
  int get hashCode =>
      profileId.hashCode ^
      points.hashCode ^
      experience.hashCode ^
      level.hashCode ^
      lifetimeEarnings.hashCode;
}
