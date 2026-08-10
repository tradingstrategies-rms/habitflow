import 'package:flutter/foundation.dart';
import '../enums/leaderboard_period.dart';

@immutable
class LeaderboardEntry {
  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int rank;
  final LeaderboardPeriod period;

  const LeaderboardEntry({
    required this.profileId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.rank,
    required this.period,
  });

  LeaderboardEntry copyWith({
    String? displayName,
    String? avatarUrl,
    int? score,
    int? rank,
    LeaderboardPeriod? period,
  }) {
    return LeaderboardEntry(
      profileId: profileId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      period: period ?? this.period,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardEntry &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          period == other.period);

  @override
  int get hashCode => profileId.hashCode ^ period.hashCode;
}
