import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/data/models/leaderboard_model.dart';
import 'package:habitflow/features/leaderboards/data/models/leaderboard_entry_model.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';

void main() {
  group('LeaderboardModel', () {
    const entry = LeaderboardEntry(
      profileId: 'p1',
      displayName: 'User 1',
      score: 100,
      rank: 1,
      period: LeaderboardPeriod.allTime,
    );

    final leaderboard = Leaderboard(
      id: 'l1',
      type: LeaderboardType.family,
      period: LeaderboardPeriod.allTime,
      entries: const [entry],
      lastUpdatedAt: DateTime(2023, 1, 1),
    );

    test('fromEntity and toEntity work correctly', () {
      final model = LeaderboardModel.fromEntity(leaderboard);
      expect(model.id, leaderboard.id);
      expect(model.entries.first.profileId, entry.profileId);
      expect(model.toEntity().id, leaderboard.id);
    });

    test('JSON serialization works correctly', () {
      final model = LeaderboardModel.fromEntity(leaderboard);
      final json = model.toJson();
      final fromJson = LeaderboardModel.fromJson(json);
      expect(fromJson.id, leaderboard.id);
      expect(fromJson.entries.first.displayName, entry.displayName);
    });
  });

  group('LeaderboardEntryModel', () {
    const entry = LeaderboardEntry(
      profileId: 'p1',
      displayName: 'User 1',
      score: 100,
      rank: 1,
      period: LeaderboardPeriod.allTime,
    );

    test('fromEntity and toEntity work correctly', () {
      final model = LeaderboardEntryModel.fromEntity(entry);
      expect(model.profileId, entry.profileId);
      expect(model.toEntity().profileId, entry.profileId);
    });

    test('JSON serialization works correctly', () {
      final model = LeaderboardEntryModel.fromEntity(entry);
      final json = model.toJson();
      final fromJson = LeaderboardEntryModel.fromJson(json);
      expect(fromJson.profileId, entry.profileId);
      expect(fromJson.displayName, entry.displayName);
      expect(fromJson.score, entry.score);
    });
  });
}
