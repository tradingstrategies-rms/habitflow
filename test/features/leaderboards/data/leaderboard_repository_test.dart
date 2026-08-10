import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/leaderboards/data/repositories/leaderboard_repository_impl.dart';
import 'package:habitflow/features/leaderboards/data/datasources/leaderboard_local_datasource.dart';
import 'package:habitflow/features/leaderboards/data/models/leaderboard_model.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';

class MockLeaderboardLocalDatasource extends Mock implements LeaderboardLocalDatasource {}

void main() {
  late LeaderboardRepositoryImpl repository;
  late MockLeaderboardLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(LeaderboardType.personal);
    registerFallbackValue(LeaderboardPeriod.allTime);
  });

  setUp(() {
    mockDatasource = MockLeaderboardLocalDatasource();
    repository = LeaderboardRepositoryImpl(mockDatasource);
    
    registerFallbackValue(LeaderboardModel(
      id: '',
      type: LeaderboardType.personal,
      period: LeaderboardPeriod.allTime,
      entries: const [],
      lastUpdatedAt: DateTime.now(),
    ));
  });

  group('LeaderboardRepositoryImpl', () {
    test('getLeaderboard calls datasource', () async {
      when(() => mockDatasource.getLeaderboard(any(), any(), familyId: any(named: 'familyId')))
          .thenAnswer((_) async => null);

      await repository.getLeaderboard(LeaderboardType.family, LeaderboardPeriod.weekly, familyId: 'f1');

      verify(() => mockDatasource.getLeaderboard(LeaderboardType.family, LeaderboardPeriod.weekly, familyId: 'f1')).called(1);
    });

    test('saveLeaderboard calls datasource', () async {
      final leaderboard = Leaderboard(
        id: 'l1',
        type: LeaderboardType.personal,
        period: LeaderboardPeriod.allTime,
        entries: const [],
        lastUpdatedAt: DateTime.now(),
      );

      when(() => mockDatasource.saveLeaderboard(any())).thenAnswer((_) async {});

      await repository.saveLeaderboard(leaderboard);

      verify(() => mockDatasource.saveLeaderboard(any())).called(1);
    });
  });
}
