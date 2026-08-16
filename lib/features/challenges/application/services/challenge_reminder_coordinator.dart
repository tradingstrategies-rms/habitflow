import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenge_providers.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';

enum ChallengeReminderKind {
  startingSoon,
  progressReminder,
  endingSoon,
}

/// [ChallengeReminderCoordinator] watches challenges and progress to trigger notifications.
class ChallengeReminderCoordinator {
  final NotificationOrchestrator _orchestrator;
  final Set<String> _notifiedIds = {};

  ChallengeReminderCoordinator(this._orchestrator);

  void evaluate(String profileId, List<Challenge> challenges, List<ChallengeProgress> allProgress) {
    final now = DateTime.now();

    for (final challenge in challenges) {
      final progress = allProgress.where((p) => p.challengeId == challenge.id).firstOrNull;
      
      if (challenge.startDate.isAfter(now) && challenge.startDate.difference(now).inHours <= 24) {
        _notify(profileId, challenge, ChallengeReminderKind.startingSoon);
      }

      if (progress != null && !progress.isCompleted && !challenge.isRecurring) {
        if (challenge.endDate.isAfter(now) && challenge.endDate.difference(now).inHours <= 24) {
          _notify(profileId, challenge, ChallengeReminderKind.endingSoon);
        }
      }

      if (challenge.isActive && progress != null && !progress.isCompleted) {
        if (now.difference(progress.lastUpdatedAt).inHours >= 48) {
          _notify(profileId, challenge, ChallengeReminderKind.progressReminder);
        }
      }
    }
  }

  Future<void> _notify(String profileId, Challenge challenge, ChallengeReminderKind kind) async {
    final stableId = 'challenge_reminder_${profileId}_${challenge.id}_${kind.name}';
    
    if (_notifiedIds.contains(stableId)) return;
    _notifiedIds.add(stableId);

    String title = '';
    String body = '';

    switch (kind) {
      case ChallengeReminderKind.startingSoon:
        title = 'Challenge starting soon';
        body = 'Your "${challenge.title}" challenge starts soon.';
        break;
      case ChallengeReminderKind.progressReminder:
        title = 'Keep your challenge going';
        body = 'You\'re making progress on "${challenge.title}". Keep the momentum alive today.';
        break;
      case ChallengeReminderKind.endingSoon:
        title = 'Challenge ending soon';
        body = 'Your "${challenge.title}" challenge ends tomorrow. Finish strong!';
        break;
    }

    final payload = NotificationPayload(
      id: stableId,
      title: title,
      body: body,
      type: NotificationType.challengeReminder,
      route: RoutePaths.challengeDetail.replaceAll(':challengeId', challenge.id),
      recipientProfileId: profileId,
      metadata: {
        'challengeId': challenge.id,
        'reminderKind': kind.name,
      },
    );

    await _orchestrator.notify(payload);
  }
}

/// Provider for Challenge reminders.
/// Scoped by session to ensure state is reset on profile switch.
final challengeReminderCoordinatorProvider = Provider<ChallengeReminderCoordinator>((ref) {
  ref.watch(activeProfileSessionProvider);
  final orchestrator = ref.watch(notificationOrchestratorProvider);
  return ChallengeReminderCoordinator(orchestrator);
});

/// Reactive listener for Challenge reminders.
/// Separated to avoid circular dependencies with the scheduler.
final challengeReminderListenerProvider = Provider<void>((ref) {
  final session = ref.watch(activeProfileSessionProvider);
  if (session == null) return;

  final coordinator = ref.watch(challengeReminderCoordinatorProvider);

  ref.listen<AsyncValue<List<Challenge>>>(
    activeChallengesProvider(session.profileId),
    (previous, next) {
      if (next.value != null) {
        coordinator.evaluate(session.profileId, next.value!, ref.read(profileProgressProvider(session.profileId)).value ?? []);
      }
    },
    fireImmediately: true,
  );

  ref.listen<AsyncValue<List<ChallengeProgress>>>(
    profileProgressProvider(session.profileId),
    (previous, next) {
      if (next.value != null) {
        coordinator.evaluate(session.profileId, ref.read(activeChallengesProvider(session.profileId)).value ?? [], next.value!);
      }
    },
    fireImmediately: true,
  );
});
