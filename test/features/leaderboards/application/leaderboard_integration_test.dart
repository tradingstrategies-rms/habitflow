import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/repositories/leaderboard_repository.dart';
import 'package:habitflow/features/leaderboards/presentation/providers/leaderboard_providers.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}
class MockRewardsRepository extends Mock implements RewardsRepository {}
class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  late ProviderContainer container;
  late MockLeaderboardRepository mockLeaderboardRepo;
  late MockRewardsRepository mockRewardsRepo;
  late MockFamilyRepository mockFamilyRepo;

  setUpAll(() {
    registerFallbackValue(LeaderboardType.personal);
    registerFallbackValue(LeaderboardPeriod.allTime);
    registerFallbackValue(Leaderboard(
      id: '',
      type: LeaderboardType.personal,
      period: LeaderboardPeriod.allTime,
      entries: const [],
      lastUpdatedAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockLeaderboardRepo = MockLeaderboardRepository();
    mockRewardsRepo = MockRewardsRepository();
    mockFamilyRepo = MockFamilyRepository();
    
    container = ProviderContainer(overrides: [
      leaderboardRepositoryProvider.overrideWithValue(mockLeaderboardRepo),
      rewardsRepositoryProvider.overrideWithValue(mockRewardsRepo),
      familyRepositoryProvider.overrideWithValue(mockFamilyRepo),
    ]);

    when(() => mockLeaderboardRepo.saveLeaderboard(any())).thenAnswer((_) async {});
  });

  group('Leaderboard Integration', () {
    test('XP change recalculation test with deterministic ranking', () async {
      final now = DateTime.now();
      final familyCircle = FamilyCircle(id: 'f1', name: 'Family', ownerProfileId: 'p1', createdAt: now);
      final p1 = FamilyProfile(id: 'p1', familyId: 'f1', displayName: 'A', profileType: ProfileType.adult, role: FamilyRole.owner, requiresPin: false, createdAt: now);
      final p2 = FamilyProfile(id: 'p2', familyId: 'f1', displayName: 'B', profileType: ProfileType.child, role: FamilyRole.child, requiresPin: false, createdAt: now);
      
      when(() => mockFamilyRepo.getFamilyCircle()).thenAnswer((_) async => familyCircle);
      when(() => mockFamilyRepo.getProfiles('f1')).thenAnswer((_) async => [p1, p2]);

      // Initialize family state
      await container.read(familyProvider.notifier).loadFamily();

      // Initial scores: equal
      final acc1 = RewardAccount(profileId: 'p1', points: 0, experience: 1000, level: 1, lifetimeEarnings: 0, lastUpdatedAt: now);
      final acc2 = RewardAccount(profileId: 'p2', points: 0, experience: 1000, level: 1, lifetimeEarnings: 0, lastUpdatedAt: now);

      when(() => mockRewardsRepo.getAccount('p1')).thenAnswer((_) async => acc1);
      when(() => mockRewardsRepo.getAccount('p2')).thenAnswer((_) async => acc2);
      when(() => mockLeaderboardRepo.getLeaderboard(any(), any(), familyId: any(named: 'familyId'))).thenAnswer((_) async => null);

      final controller = container.read(leaderboardControllerProvider);
      final lb = await controller.refreshLeaderboard(LeaderboardType.family, LeaderboardPeriod.allTime, familyId: 'f1');

      expect(lb.entries.length, 2);
      // Equal scores -> sorted by name (A before B)
      expect(lb.entries[0].profileId, 'p1'); 

      // Update XP for p2
      final acc2Updated = acc2.copyWith(experience: 2000);
      when(() => mockRewardsRepo.getAccount('p2')).thenAnswer((_) async => acc2Updated);

      final lbUpdated = await controller.refreshLeaderboard(LeaderboardType.family, LeaderboardPeriod.allTime, familyId: 'f1');
      expect(lbUpdated.entries[0].profileId, 'p2'); // p2 now has more XP
    });

    test('stale cache refresh logic correctly detects old periods', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 8));
      final oldLeaderboard = Leaderboard(
        id: 'old',
        type: LeaderboardType.family,
        period: LeaderboardPeriod.weekly,
        entries: const [],
        lastUpdatedAt: oldDate,
      );

      when(() => mockLeaderboardRepo.getLeaderboard(any(), any(), familyId: any(named: 'familyId')))
          .thenAnswer((_) async => oldLeaderboard);
      
      when(() => mockRewardsRepo.getAccount(any())).thenAnswer((_) async => null);
      when(() => mockRewardsRepo.getTransactions(any())).thenAnswer((_) async => []);

      final controller = container.read(leaderboardControllerProvider);
      final lb = await controller.getOrRefreshLeaderboard(LeaderboardType.family, LeaderboardPeriod.weekly, familyId: 'f1');

      expect(lb?.id, isNot('old'));
      expect(lb?.lastUpdatedAt.isAfter(oldDate), isTrue);
    });
  });
}
