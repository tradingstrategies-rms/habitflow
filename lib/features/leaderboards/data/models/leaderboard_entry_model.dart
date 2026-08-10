import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/enums/leaderboard_period.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.profileId,
    required super.displayName,
    super.avatarUrl,
    required super.score,
    required super.rank,
    required super.period,
  });

  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entity) {
    return LeaderboardEntryModel(
      profileId: entity.profileId,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      score: entity.score,
      rank: entity.rank,
      period: entity.period,
    );
  }

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      profileId: json['profileId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      period: LeaderboardPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => LeaderboardPeriod.allTime,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'score': score,
      'rank': rank,
      'period': period.name,
    };
  }

  LeaderboardEntry toEntity() => this;
}
