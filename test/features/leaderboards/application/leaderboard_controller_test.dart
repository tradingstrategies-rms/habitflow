import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/repositories/leaderboard_repository.dart';
import 'package:habitflow/features/leaderboards/application/controllers/leaderboard_controller.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/application/controllers/rewards_controller.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}
class MockRewardsRepository extends Mock implements RewardsRepository {}
class MockRewardsController extends Mock implements RewardsController {}
class MockRef extends Mock implements Ref {}

void main() {
  late LeaderboardController controller;
  late MockLeaderboardRepository mockRepo;
  late MockRewardsRepository mockRewardsRepo;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(LeaderboardType.personal);
    registerFallbackValue(LeaderboardPeriod.allTime);
  });

  setUp(() {
    mockRepo = MockLeaderboardRepository();
    mockRewardsRepo = MockRewardsRepository();
    mockRef = MockRef();
    controller = LeaderboardController(mockRepo, mockRef);

    registerFallbackValue(Leaderboard(
      id: '',
      type: LeaderboardType.personal,
      period: LeaderboardPeriod.allTime,
      entries: const [],
      lastUpdatedAt: DateTime.now(),
    ));

    when(() => mockRef.read(rewardsRepositoryProvider)).thenReturn(mockRewardsRepo);
  });

  group('LeaderboardController', () {
    test('refreshLeaderboard sorts and ranks family entries correctly', () async {
      final familyCircle = FamilyCircle(id: 'f1', name: 'Family', ownerProfileId: 'p1', createdAt: DateTime.now());
      final p1 = FamilyProfile(id: 'p1', familyId: 'f1', displayName: 'User 1', profileType: ProfileType.adult, role: FamilyRole.owner, requiresPin: false, createdAt: DateTime.now());
      final p2 = FamilyProfile(id: 'p2', familyId: 'f1', displayName: 'User 2', profileType: ProfileType.child, role: FamilyRole.child, requiresPin: false, createdAt: DateTime.now());
      
      final familyState = FamilyState(circle: familyCircle, profiles: [p1, p2]);
      
      final acc1 = RewardAccount(profileId: 'p1', points: 0, experience: 1000, level: 1, lifetimeEarnings: 0, lastUpdatedAt: DateTime.now());
      final acc2 = RewardAccount(profileId: 'p2', points: 0, experience: 2000, level: 1, lifetimeEarnings: 0, lastUpdatedAt: DateTime.now());

      when(() => mockRef.read(familyProvider)).thenReturn(familyState);
      when(() => mockRewardsRepo.getAccount('p1')).thenAnswer((_) async => acc1);
      when(() => mockRewardsRepo.getAccount('p2')).thenAnswer((_) async => acc2);
      when(() => mockRepo.saveLeaderboard(any())).thenAnswer((_) async {});

      final result = await controller.refreshLeaderboard(LeaderboardType.family, LeaderboardPeriod.allTime, familyId: 'f1');

      expect(result.entries.length, 2);
      expect(result.entries[0].profileId, 'p2'); // p2 has more XP
      expect(result.entries[0].rank, 1);
      expect(result.entries[1].profileId, 'p1');
      expect(result.entries[1].rank, 2);
      
      verify(() => mockRepo.saveLeaderboard(any())).called(1);
    });
  });
}
