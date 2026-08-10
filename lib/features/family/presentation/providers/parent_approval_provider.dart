import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/entities/parent_approval.dart';
import 'package:habitflow/features/family/domain/enums/approval_status.dart';
import 'package:habitflow/features/family/domain/entities/family_activity.dart';
import 'package:habitflow/features/family/domain/enums/family_activity_type.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/application/providers/reminder_scheduler_providers.dart';
import 'package:uuid/uuid.dart';

final approvalNotifierProvider = StateNotifierProvider<ApprovalNotifier, AsyncValue<void>>((ref) {
  return ApprovalNotifier(ref.watch(familyRepositoryProvider), ref);
});

final pendingApprovalsProvider = FutureProvider.family<List<ParentApproval>, String>((ref, parentId) async {
  final repository = ref.watch(familyRepositoryProvider);
  return await repository.getPendingApprovals(parentId); 
});

final habitPendingApprovalProvider = Provider.family<ParentApproval?, String>((ref, habitId) {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return null;

  final approvalsAsync = ref.watch(allPendingApprovalsProvider);
  return approvalsAsync.maybeWhen(
    data: (approvals) {
      try {
        return approvals.firstWhere(
          (a) => a.habitId == habitId && 
                 a.status == ApprovalStatus.pending && 
                 a.childProfileId == activeProfile.id,
        );
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

// Better way to get pending approvals without needing parentId if we just want all for the family
final allPendingApprovalsProvider = FutureProvider<List<ParentApproval>>((ref) async {
  final repository = ref.watch(familyRepositoryProvider);
  // In a real app, we'd filter by familyId.
  return await repository.getPendingApprovals('all');
});

class ApprovalNotifier extends StateNotifier<AsyncValue<void>> {
  final FamilyRepository _repository;
  final Ref _ref;

  ApprovalNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> requestApproval({
    required String childId,
    required String childName,
    required String habitId,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final approval = ParentApproval(
        id: const Uuid().v4(),
        childProfileId: childId,
        childName: childName,
        habitId: habitId,
        status: ApprovalStatus.pending,
        createdAt: DateTime.now(),
        note: note,
      );
      await _repository.createPendingApproval(approval);

      final habit = await _ref.read(habitByIdProvider(habitId).future);
      
      // Record Activity
      final familyId = _ref.read(familyProvider).circle?.id;
      if (familyId != null) {
        await _repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: familyId,
          profileId: childId,
          profileName: childName,
          type: FamilyActivityType.awaitingApproval,
          description: '$childName completed "${habit?.title ?? 'a habit'}" and is awaiting approval',
          metadata: habitId,
          timestamp: DateTime.now(),
        ));
      }
      
      // Notify Parent (Sprint 8: Push Notifications, Sprint 7: Local Notification)
      try {
        final habit = await _ref.read(habitByIdProvider(habitId).future);
        final adapter = _ref.read(localNotificationAdapterProvider);
        await adapter.scheduleOneTimeNotification(
          id: approval.id.hashCode,
          title: 'Approval Requested',
          body: '$childName completed "${habit?.title ?? 'a habit'}" and is awaiting approval.',
          scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
        );
      } catch (e) {
        // Log error but don't fail the approval request
        debugPrint('Failed to send local notification: $e');
      }

      _ref.invalidate(allPendingApprovalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> approve(ParentApproval approval) async {
    state = const AsyncValue.loading();
    try {
      await _repository.approveHabit(approval.id);

      final habit = await _ref.read(habitByIdProvider(approval.habitId).future);
      final familyId = _ref.read(familyProvider).circle?.id;
      if (familyId != null) {
        await _repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: familyId,
          profileId: approval.childProfileId,
          profileName: approval.childName,
          type: FamilyActivityType.completionApproved,
          description: 'Parent approved ${approval.childName}\'s completion of "${habit?.title ?? 'a habit'}"',
          metadata: approval.habitId,
          timestamp: DateTime.now(),
        ));
      }

      final habitController = _ref.read(habitControllerProvider);
      // Ensure we complete for today, passing the child's profile ID
      await habitController.completeHabit(
        approval.habitId, 
        DateTime.now(), 
        profileId: approval.childProfileId,
      );
      _ref.invalidate(allPendingApprovalsProvider);
      // Also invalidate habit completion providers
      _ref.invalidate(todayCompletionProvider(approval.habitId));
      _ref.invalidate(anyTodayCompletionProvider(approval.habitId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reject(ParentApproval approval) async {
    state = const AsyncValue.loading();
    try {
      await _repository.rejectHabit(approval.id);

      final habit = await _ref.read(habitByIdProvider(approval.habitId).future);
      final familyId = _ref.read(familyProvider).circle?.id;
      if (familyId != null) {
        await _repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: familyId,
          profileId: approval.childProfileId,
          profileName: approval.childName,
          type: FamilyActivityType.completionRejected,
          description: 'Parent rejected ${approval.childName}\'s completion of "${habit?.title ?? 'a habit'}"',
          metadata: approval.habitId,
          timestamp: DateTime.now(),
        ));
      }

      _ref.invalidate(allPendingApprovalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
