import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/enums/redemption_status.dart';
import '../../domain/repositories/reward_store_repository.dart';
import '../../presentation/providers/reward_store_providers.dart';
import '../../data/models/reward_redemption_model.dart';
import '../../../rewards/application/controllers/rewards_controller.dart';
import '../../../rewards/presentation/providers/reward_account_provider.dart';
import '../../../family/domain/enums/profile_type.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../rewards/domain/entities/reward_transaction.dart';
import '../../../rewards/domain/enums/reward_type.dart';
import '../../../rewards/domain/enums/reward_source.dart';
import '../../../family/domain/enums/family_role.dart';
import '../../../family/presentation/providers/active_profile_provider.dart';
import '../../../../core/sync/services/gamification_sync_service.dart';
import '../../../../core/sync/models/sync_operation.dart';

class RewardStoreController {
  final RewardStoreRepository _repository;
  final RewardsController _rewardsController;
  final Ref _ref;

  RewardStoreController(this._repository, this._rewardsController, this._ref);

  Future<void> redeemItem(String profileId, String rewardItemId) async {
    final item = await _repository.getItemById(rewardItemId);
    if (item == null) throw Exception('Reward item not found');
    if (!item.isAvailable) throw Exception('Reward item is not available');

    // 1. Verify eligibility
    if (item.eligibleProfileIds.isNotEmpty && !item.eligibleProfileIds.contains(profileId)) {
      throw Exception('Profile not eligible for this reward');
    }

    // 2. Verify sufficient points
    final account = await _ref.read(rewardAccountProvider(profileId).future);
    if (account == null || account.points < item.pointsCost) {
      throw Exception('Insufficient points');
    }

    // 3. Determine status (Children might need approval)
    final familyState = _ref.read(familyProvider);
    final profile = familyState.profiles.firstWhere((p) => p.id == profileId);
    
    final bool needsApproval = profile.profileType == ProfileType.child;
    final status = needsApproval ? RedemptionStatus.pending : RedemptionStatus.approved;

    // 4. Record Redemption
    final redemption = RewardRedemption(
      id: const Uuid().v4(),
      profileId: profileId,
      rewardItemId: rewardItemId,
      pointsSpent: item.pointsCost,
      status: status,
      createdAt: DateTime.now(),
    );

    await _repository.saveRedemption(redemption);

    // 5. If approved, deduct points immediately
    if (status == RedemptionStatus.approved) {
      await _deductPoints(profileId, item);
    }

    _refreshState(profileId);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: profileId,
      type: SyncOperationType.saveRedemption,
      data: RewardRedemptionModel.fromEntity(redemption).toJson(),
      createdAt: redemption.createdAt,
    ));
  }

  Future<void> approveRedemption(String redemptionId) async {
    _ensureParentPermission();

    final redemption = await _repository.getRedemptionById(redemptionId);
    if (redemption == null) throw Exception('Redemption not found');
    if (redemption.status != RedemptionStatus.pending) {
      throw Exception('Redemption is not pending');
    }

    final item = await _repository.getItemById(redemption.rewardItemId);
    if (item == null) throw Exception('Reward item not found');

    // Verify sufficient points AGAIN at time of approval
    final account = await _ref.read(rewardAccountProvider(redemption.profileId).future);
    if (account == null || account.points < redemption.pointsSpent) {
      throw Exception('Insufficient points for approval');
    }

    // Deduct points
    await _deductPoints(redemption.profileId, item);

    // Update status
    final updated = redemption.copyWith(status: RedemptionStatus.approved);
    await _repository.saveRedemption(updated);

    _refreshState(redemption.profileId);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: redemption.profileId,
      type: SyncOperationType.saveRedemption,
      data: RewardRedemptionModel.fromEntity(updated).toJson(),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> rejectRedemption(String redemptionId) async {
    _ensureParentPermission();

    final redemption = await _repository.getRedemptionById(redemptionId);
    if (redemption == null) throw Exception('Redemption not found');
    if (redemption.status != RedemptionStatus.pending) {
      throw Exception('Only pending redemptions can be rejected');
    }

    final updated = redemption.copyWith(status: RedemptionStatus.rejected);
    await _repository.saveRedemption(updated);

    _refreshState(redemption.profileId);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: redemption.profileId,
      type: SyncOperationType.saveRedemption,
      data: RewardRedemptionModel.fromEntity(updated).toJson(),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> fulfillRedemption(String redemptionId) async {
    _ensureParentPermission();

    final redemption = await _repository.getRedemptionById(redemptionId);
    if (redemption == null) throw Exception('Redemption not found');
    if (redemption.status != RedemptionStatus.approved) {
      throw Exception('Only approved redemptions can be fulfilled');
    }

    final updated = redemption.copyWith(status: RedemptionStatus.fulfilled);
    await _repository.saveRedemption(updated);

    _refreshState(redemption.profileId);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: redemption.profileId,
      type: SyncOperationType.saveRedemption,
      data: RewardRedemptionModel.fromEntity(updated).toJson(),
      createdAt: DateTime.now(),
    ));
  }

  void _ensureParentPermission() {
    final activeProfile = _ref.read(activeProfileProvider);
    if (activeProfile == null) throw Exception('No active profile');
    
    final bool isParent = activeProfile.role == FamilyRole.owner || 
                          activeProfile.role == FamilyRole.parent;
    
    if (!isParent) {
      throw Exception('Only parents can manage redemptions');
    }
  }

  Future<void> _deductPoints(String profileId, RewardItem item) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: -item.pointsCost,
      type: RewardType.points,
      source: RewardSource.rewardRedemption,
      referenceId: item.id,
      description: 'Redeemed: ${item.title}',
      createdAt: DateTime.now(),
    );

    await _rewardsController.addTransaction(transaction);
  }

  void _queueSync(SyncOperation operation) {
    _ref.read(gamificationSyncServiceProvider).queueOperation(operation).catchError((e) {
      // Log silently
    });
  }

  void _refreshState(String profileId) {
    _ref.invalidate(redemptionHistoryProvider(profileId));
    _ref.invalidate(rewardAccountProvider(profileId));
    _ref.invalidate(allRedemptionsProvider);
  }
}
