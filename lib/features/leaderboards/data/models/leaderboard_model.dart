import '../../domain/entities/leaderboard.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';
import 'leaderboard_entry_model.dart';

class LeaderboardModel extends Leaderboard {
  const LeaderboardModel({
    required super.id,
    required super.type,
    required super.period,
    required super.entries,
    required super.lastUpdatedAt,
  });

  factory LeaderboardModel.fromEntity(Leaderboard entity) {
    return LeaderboardModel(
      id: entity.id,
      type: entity.type,
      period: entity.period,
      entries: entity.entries,
      lastUpdatedAt: entity.lastUpdatedAt,
    );
  }

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id']?.toString() ?? '',
      type: LeaderboardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LeaderboardType.personal,
      ),
      period: LeaderboardPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => LeaderboardPeriod.allTime,
      ),
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntryModel.fromJson(e))
              .toList() ??
          const [],
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'period': period.name,
      'entries': entries
          .map((e) => LeaderboardEntryModel.fromEntity(e).toJson())
          .toList(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  Leaderboard toEntity() => this;
}
