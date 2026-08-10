import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/application/controllers/leaderboard_controller.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/domain/repositories/leaderboard_repository.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}
class MockRewardsRepository extends Mock implements RewardsRepository {}
class MockRef extends Mock implements Ref {}

void main() {
  late LeaderboardController controller;
  late MockLeaderboardRepository mockRepo;
  late MockRewardsRepository mockRewardsRepo;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(Leaderboard(
      id: '',
      type: LeaderboardType.personal,
      period: LeaderboardPeriod.allTime,
      entries: const [],
      lastUpdatedAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepo = MockLeaderboardRepository();
    mockRewardsRepo = MockRewardsRepository();
    mockRef = MockRef();
    controller = LeaderboardController(mockRepo, mockRef);

    when(() => mockRef.read(rewardsRepositoryProvider)).thenReturn(mockRewardsRepo);
    when(() => mockRepo.saveLeaderboard(any())).thenAnswer((_) async {});
  });

  group('Leaderboard Sorting Regression', () {
    test('Leaderboard sorts by score DESC and then by name ASC', () async {
      final circle = FamilyCircle(id: 'f1', name: 'Family', ownerProfileId: 'p1', createdAt: DateTime.now());
      final profiles = [
        FamilyProfile(id: 'p1', familyId: 'f1', displayName: 'Charlie', profileType: ProfileType.adult, role: FamilyRole.owner, requiresPin: false, createdAt: DateTime.now()),
        FamilyProfile(id: 'p2', familyId: 'f1', displayName: 'Alice', profileType: ProfileType.adult, role: FamilyRole.parent, requiresPin: false, createdAt: DateTime.now()),
        FamilyProfile(id: 'p3', familyId: 'f1', displayName: 'Bob', profileType: ProfileType.adult, role: FamilyRole.parent, requiresPin: false, createdAt: DateTime.now()),
      ];

      when(() => mockRef.read(familyProvider)).thenReturn(FamilyState(circle: circle, profiles: profiles));
      
      // Alice and Bob have 100 XP, Charlie has 50 XP
      when(() => mockRewardsRepo.getAccount('p1')).thenAnswer((_) async => RewardAccount(profileId: 'p1', points: 0, experience: 50, level: 1, lifetimeEarnings: 50, lastUpdatedAt: DateTime.now()));
      when(() => mockRewardsRepo.getAccount('p2')).thenAnswer((_) async => RewardAccount(profileId: 'p2', points: 0, experience: 100, level: 1, lifetimeEarnings: 100, lastUpdatedAt: DateTime.now()));
      when(() => mockRewardsRepo.getAccount('p3')).thenAnswer((_) async => RewardAccount(profileId: 'p3', points: 0, experience: 100, level: 1, lifetimeEarnings: 100, lastUpdatedAt: DateTime.now()));

      final result = await controller.refreshLeaderboard(LeaderboardType.family, LeaderboardPeriod.allTime, familyId: 'f1');

      // Expected order:
      // 1. Alice (100)
      // 2. Bob (100)
      // 3. Charlie (50)
      expect(result.entries[0].displayName, 'Alice');
      expect(result.entries[0].rank, 1);
      expect(result.entries[1].displayName, 'Bob');
      expect(result.entries[1].rank, 2);
      expect(result.entries[2].displayName, 'Charlie');
      expect(result.entries[2].rank, 3);
    });
  });
}
