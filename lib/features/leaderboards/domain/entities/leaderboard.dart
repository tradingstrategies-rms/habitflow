import 'package:flutter/foundation.dart';
import '../enums/leaderboard_type.dart';
import '../enums/leaderboard_period.dart';
import 'leaderboard_entry.dart';

@immutable
class Leaderboard {
  final String id;
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdatedAt;

  const Leaderboard({
    required this.id,
    required this.type,
    required this.period,
    required this.entries,
    required this.lastUpdatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Leaderboard &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
