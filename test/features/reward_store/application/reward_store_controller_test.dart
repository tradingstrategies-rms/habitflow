import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';
import 'package:habitflow/features/reward_store/domain/repositories/reward_store_repository.dart';
import 'package:habitflow/features/reward_store/application/controllers/reward_store_controller.dart';
import 'package:habitflow/features/rewards/application/controllers/rewards_controller.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/core/sync/services/gamification_sync_service.dart';
import 'package:habitflow/core/sync/models/sync_operation.dart';

class MockRewardStoreRepository extends Mock implements RewardStoreRepository {}
class MockRewardsController extends Mock implements RewardsController {}
class MockGamificationSyncService extends Mock implements GamificationSyncService {}
class MockRef extends Mock implements Ref {}

final _fallbackProvider = Provider<void>((ref) {});

void main() {
  late RewardStoreController controller;
  late MockRewardStoreRepository mockRepo;
  late MockRewardsController mockRewardsController;
  late MockGamificationSyncService mockSync;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(_fallbackProvider);
    registerFallbackValue(RedemptionStatus.approved);
    registerFallbackValue(RewardTransaction(
      id: '', profileId: '', amount: 0, type: RewardType.points, source: RewardSource.rewardRedemption, description: '', createdAt: DateTime.now()
    ));
    registerFallbackValue(SyncOperation(
      id: '', profileId: '', type: SyncOperationType.addTransaction, data: const {}, createdAt: DateTime.now()
    ));
  });

  setUp(() {
    mockRepo = MockRewardStoreRepository();
    mockRewardsController = MockRewardsController();
    mockSync = MockGamificationSyncService();
    mockRef = MockRef();
    controller = RewardStoreController(mockRepo, mockRewardsController, mockRef);

    registerFallbackValue(RewardRedemption(
      id: '', profileId: '', rewardItemId: '', pointsSpent: 0, status: RedemptionStatus.pending, createdAt: DateTime.now()
    ));
    
    when(() => mockRef.invalidate(any())).thenReturn(null);
    when(() => mockRef.read(gamificationSyncServiceProvider)).thenReturn(mockSync);
    when(() => mockSync.queueOperation(any())).thenAnswer((_) async {});
  });

  group('RewardStoreController', () {
    const item = RewardItem(
      id: 'i1',
      title: 'Coffee',
      description: 'Free coffee',
      pointsCost: 100,
      category: RewardCategory.other,
    );

    final adultProfile = FamilyProfile(
      id: 'p1', familyId: 'f1', displayName: 'Adult', profileType: ProfileType.adult, role: FamilyRole.owner, requiresPin: false, createdAt: DateTime.now()
    );

    final childProfile = FamilyProfile(
      id: 'c1', familyId: 'f1', displayName: 'Child', profileType: ProfileType.child, role: FamilyRole.child, requiresPin: false, createdAt: DateTime.now()
    );

    final account = RewardAccount(
      profileId: 'p1', points: 200, experience: 0, level: 1, lifetimeEarnings: 200, lastUpdatedAt: DateTime.now()
    );

    test('redeemItem successful for adult', () async {
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => item);
      when(() => mockRef.read(rewardAccountProvider('p1').future)).thenAnswer((_) async => account);
      when(() => mockRef.read(familyProvider)).thenReturn(FamilyState(profiles: [adultProfile]));
      when(() => mockRepo.saveRedemption(any())).thenAnswer((_) async {});
      when(() => mockRewardsController.addTransaction(any())).thenAnswer((_) async {});

      await controller.redeemItem('p1', 'i1');

      verify(() => mockRepo.saveRedemption(any(
        that: isA<RewardRedemption>().having((r) => r.status, 'status', RedemptionStatus.approved)
      ))).called(1);
      
      verify(() => mockRewardsController.addTransaction(any())).called(1);
    });

    test('approveRedemption works and deducts points', () async {
      final redemption = RewardRedemption(
        id: 'r1', profileId: 'c1', rewardItemId: 'i1', pointsSpent: 100, status: RedemptionStatus.pending, createdAt: DateTime.now()
      );

      final childAccount = RewardAccount(
        profileId: 'c1', points: 200, experience: 0, level: 1, lifetimeEarnings: 200, lastUpdatedAt: DateTime.now()
      );

      when(() => mockRef.read(activeProfileProvider)).thenReturn(adultProfile);
      when(() => mockRepo.getRedemptionById('r1')).thenAnswer((_) async => redemption);
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => item);
      when(() => mockRef.read(rewardAccountProvider('c1').future)).thenAnswer((_) async => childAccount);
      when(() => mockRewardsController.addTransaction(any())).thenAnswer((_) async {});
      when(() => mockRepo.saveRedemption(any())).thenAnswer((_) async {});

      await controller.approveRedemption('r1');

      verify(() => mockRepo.saveRedemption(any(
        that: isA<RewardRedemption>().having((r) => r.status, 'status', RedemptionStatus.approved)
      ))).called(1);
      
      verify(() => mockRewardsController.addTransaction(any(
        that: isA<RewardTransaction>().having((t) => t.amount, 'amount', -100)
      ))).called(1);
    });

    test('approveRedemption fails if not parent', () async {
      when(() => mockRef.read(activeProfileProvider)).thenReturn(childProfile);
      expect(() => controller.approveRedemption('r1'), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Only parents'))));
    });

    test('rejectRedemption works', () async {
      final redemption = RewardRedemption(
        id: 'r1', profileId: 'c1', rewardItemId: 'i1', pointsSpent: 100, status: RedemptionStatus.pending, createdAt: DateTime.now()
      );

      when(() => mockRef.read(activeProfileProvider)).thenReturn(adultProfile);
      when(() => mockRepo.getRedemptionById('r1')).thenAnswer((_) async => redemption);
      when(() => mockRepo.saveRedemption(any())).thenAnswer((_) async {});

      await controller.rejectRedemption('r1');

      verify(() => mockRepo.saveRedemption(any(
        that: isA<RewardRedemption>().having((r) => r.status, 'status', RedemptionStatus.rejected)
      ))).called(1);
      
      verifyNever(() => mockRewardsController.addTransaction(any()));
    });

    test('fulfillRedemption works', () async {
      final redemption = RewardRedemption(
        id: 'r1', profileId: 'c1', rewardItemId: 'i1', pointsSpent: 100, status: RedemptionStatus.approved, createdAt: DateTime.now()
      );

      when(() => mockRef.read(activeProfileProvider)).thenReturn(adultProfile);
      when(() => mockRepo.getRedemptionById('r1')).thenAnswer((_) async => redemption);
      when(() => mockRepo.saveRedemption(any())).thenAnswer((_) async {});

      await controller.fulfillRedemption('r1');

      verify(() => mockRepo.saveRedemption(any(
        that: isA<RewardRedemption>().having((r) => r.status, 'status', RedemptionStatus.fulfilled)
      ))).called(1);
    });

    test('redeemItem pending for child', () async {
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => item);
      when(() => mockRef.read(rewardAccountProvider('c1').future)).thenAnswer((_) async => account.copyWith()); // same points
      when(() => mockRef.read(familyProvider)).thenReturn(FamilyState(profiles: [childProfile]));
      when(() => mockRepo.saveRedemption(any())).thenAnswer((_) async {});

      await controller.redeemItem('c1', 'i1');

      verify(() => mockRepo.saveRedemption(any(
        that: isA<RewardRedemption>().having((r) => r.status, 'status', RedemptionStatus.pending)
      ))).called(1);
      
      // No point deduction for pending
      verifyNever(() => mockRewardsController.addTransaction(any()));
    });

    test('redeemItem fails if insufficient points', () async {
      final poorAccount = account.copyWith(points: 50);
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => item);
      when(() => mockRef.read(rewardAccountProvider('p1').future)).thenAnswer((_) async => poorAccount);
      
      expect(() => controller.redeemItem('p1', 'i1'), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Insufficient points'))));
    });

    test('redeemItem fails if item not available', () async {
      const unavailableItem = RewardItem(id: 'i1', title: 'T', description: 'D', pointsCost: 10, category: RewardCategory.other, isAvailable: false);
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => unavailableItem);
      
      expect(() => controller.redeemItem('p1', 'i1'), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Reward item is not available'))));
    });

    test('redeemItem respect eligibility', () async {
      const restrictedItem = RewardItem(id: 'i1', title: 'T', description: 'D', pointsCost: 10, category: RewardCategory.other, eligibleProfileIds: ['other_p']);
      when(() => mockRepo.getItemById('i1')).thenAnswer((_) async => restrictedItem);
      
      expect(() => controller.redeemItem('p1', 'i1'), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Profile not eligible'))));
    });
  });
}
