import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/permission_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/application/providers/family_permission_providers.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';
import 'package:habitflow/features/reward_store/presentation/providers/reward_store_providers.dart';

/// [RewardApprovalNotificationCoordinator] monitors new reward redemption requests.
class RewardApprovalNotificationCoordinator {
  final NotificationOrchestrator _orchestrator;
  final Set<String> _notifiedRedemptionIds = {};

  RewardApprovalNotificationCoordinator(this._orchestrator);

  void processRedemptions(Ref ref, List<RewardRedemption> redemptions) {
    final pending = redemptions.where((r) => r.status == RedemptionStatus.pending).toList();
    if (pending.isEmpty) return;

    final activeProfile = ref.read(activeProfileProvider);
    if (activeProfile == null) return;

    final permissionService = ref.read(familyPermissionServiceProvider);
    if (permissionService.isChild(activeProfile)) return;

    if (!permissionService.hasPermission(activeProfile, PermissionType.approveChildTask)) return;

    for (final redemption in pending) {
      _evaluateRedemption(ref, redemption, activeProfile);
    }
  }

  void _evaluateRedemption(Ref ref, RewardRedemption redemption, FamilyProfile activeParent) {
    if (_notifiedRedemptionIds.contains(redemption.id)) return;

    if (redemption.profileId == activeParent.id) return; 

    final familyState = ref.read(familyProvider);
    final childProfile = familyState.profiles.where((p) => p.id == redemption.profileId).firstOrNull;

    if (childProfile == null || childProfile.familyId != activeParent.familyId) return;

    _notifiedRedemptionIds.add(redemption.id);
    _triggerNotification(ref, redemption, childProfile, activeParent);
  }

  Future<void> _triggerNotification(
    Ref ref,
    RewardRedemption redemption, 
    FamilyProfile child,
    FamilyProfile parent,
  ) async {
    final item = await ref.read(rewardItemByIdProvider(redemption.rewardItemId).future);
    final rewardTitle = item?.title ?? 'a reward';
    
    final payload = NotificationPayload(
      id: 'reward_approval_${child.familyId}_${redemption.id}_${parent.id}',
      title: 'Reward approval needed',
      body: '${child.displayName} has requested "$rewardTitle" and is waiting for your approval.',
      type: NotificationType.rewardApproval,
      route: RoutePaths.rewardStore, 
      recipientProfileId: parent.id,
      familyId: child.familyId,
      metadata: {
        'redemptionId': redemption.id,
      },
    );

    await _orchestrator.notify(payload);
  }
}

/// Provider for Reward Approval notifications.
final rewardApprovalNotificationCoordinatorProvider = Provider<RewardApprovalNotificationCoordinator>((ref) {
  ref.watch(activeProfileSessionProvider);
  final orchestrator = ref.watch(notificationOrchestratorProvider);
  final coordinator = RewardApprovalNotificationCoordinator(orchestrator);

  ref.listen<AsyncValue<List<RewardRedemption>>>(
    allRedemptionsProvider,
    (previous, next) {
      final redemptions = next.value;
      if (redemptions != null) {
        coordinator.processRedemptions(ref, redemptions);
      }
    },
    fireImmediately: true,
  );

  ref.listen<FamilyProfile?>(
    activeProfileProvider,
    (previous, next) {
      if (next == null) return;
      final redemptions = ref.read(allRedemptionsProvider).value;
      if (redemptions != null) {
        coordinator.processRedemptions(ref, redemptions);
      }
    },
    fireImmediately: true,
  );

  return coordinator;
});
