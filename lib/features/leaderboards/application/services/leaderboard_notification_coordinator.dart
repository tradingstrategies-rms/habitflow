import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/presentation/providers/leaderboard_providers.dart';

/// [LeaderboardNotificationCoordinator] monitors leaderboard ranking changes.
class LeaderboardNotificationCoordinator {
  final NotificationOrchestrator _orchestrator;
  final Map<String, int> _lastRanks = {};
  final Set<String> _notifiedMilestones = {};

  LeaderboardNotificationCoordinator(this._orchestrator);

  void processTransition(
    LeaderboardType type,
    LeaderboardPeriod period,
    String profileId,
    LeaderboardEntry? currentEntry,
    String? familyId,
  ) {
    final stateKey = '${type.name}_${period.name}_$profileId';
    final int? previousRank = _lastRanks[stateKey];
    final int? currentRank = currentEntry?.rank;

    if (currentRank != null) {
      _lastRanks[stateKey] = currentRank;
    }

    if (currentRank == null) return;

    if (previousRank == null) {
      _notifyEntered(type, period, profileId, currentRank, familyId);
      _checkMilestones(type, period, profileId, currentRank, familyId);
      return;
    }

    if (currentRank < previousRank) {
      final improvement = previousRank - currentRank;
      if (improvement >= 2 || _isCrossingMilestone(previousRank, currentRank)) {
        _notifyRankImproved(type, period, profileId, previousRank, currentRank, familyId);
      }
    } 
    else if (currentRank > previousRank) {
      final decline = currentRank - previousRank;
      if (decline >= 2 || _isCrossingMilestone(previousRank, currentRank)) {
        _notifyRankDeclined(type, period, profileId, previousRank, currentRank, familyId);
      }
    }

    _checkMilestones(type, period, profileId, currentRank, familyId);
  }

  bool _isCrossingMilestone(int prev, int curr) {
    const milestones = [10, 5, 3, 1];
    for (final m in milestones) {
      if ((prev > m && curr <= m) || (prev <= m && curr > m)) return true;
    }
    return false;
  }

  void _checkMilestones(LeaderboardType type, LeaderboardPeriod period, String profileId, int rank, String? familyId) {
    final milestones = {
      1: 'Reached #1!',
      3: 'Top 3!',
      5: 'Top 5!',
      10: 'Top 10!',
    };

    for (final entry in milestones.entries) {
      final mRank = entry.key;
      final mLabel = entry.value;
      
      if (rank <= mRank) {
        final milestoneKey = '${type.name}_${period.name}_${profileId}_$mRank';
        if (!_notifiedMilestones.contains(milestoneKey)) {
          _notifiedMilestones.add(milestoneKey);
          _notifyMilestone(type, period, profileId, rank, mLabel, familyId);
          break; 
        }
      }
    }
  }

  void _notifyEntered(LeaderboardType type, LeaderboardPeriod period, String profileId, int rank, String? familyId) {
    _sendNotification(
      id: 'leaderboard_entered_${type.name}_${period.name}_$profileId',
      profileId: profileId,
      title: "You're on the board!",
      body: "You've entered the ${_getScopeLabel(type)} leaderboard at #$rank.",
      familyId: familyId,
    );
  }

  void _notifyRankImproved(LeaderboardType type, LeaderboardPeriod period, String profileId, int oldRank, int newRank, String? familyId) {
    _sendNotification(
      id: 'leaderboard_improved_${type.name}_${period.name}_${profileId}_$newRank',
      profileId: profileId,
      title: "You're climbing!",
      body: "You moved from #$oldRank to #$newRank on the ${_getScopeLabel(type)} leaderboard.",
      familyId: familyId,
    );
  }

  void _notifyRankDeclined(LeaderboardType type, LeaderboardPeriod period, String profileId, int oldRank, int newRank, String? familyId) {
    _sendNotification(
      id: 'leaderboard_declined_${type.name}_${period.name}_${profileId}_$newRank',
      profileId: profileId,
      title: "Keep going!",
      body: "Your ${_getScopeLabel(type)} leaderboard position changed from #$oldRank to #$newRank.",
      familyId: familyId,
    );
  }

  void _notifyMilestone(LeaderboardType type, LeaderboardPeriod period, String profileId, int rank, String label, String? familyId) {
    _sendNotification(
      id: 'leaderboard_milestone_${type.name}_${period.name}_${profileId}_$rank',
      profileId: profileId,
      title: label,
      body: "You've reached #$rank on the ${_getScopeLabel(type)} leaderboard.",
      familyId: familyId,
    );
  }

  String _getScopeLabel(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.family: return 'Family';
      case LeaderboardType.friends: return 'Friends';
      case LeaderboardType.personal: return 'Personal';
    }
  }

  Future<void> _sendNotification({
    required String id,
    required String profileId,
    required String title,
    required String body,
    String? familyId,
  }) async {
    final payload = NotificationPayload(
      id: id,
      title: title,
      body: body,
      type: NotificationType.leaderboard,
      route: RoutePaths.leaderboard,
      recipientProfileId: profileId,
      familyId: familyId,
    );

    await _orchestrator.notify(payload);
  }
}

/// Provider for Leaderboard engagement notifications.
final leaderboardNotificationCoordinatorProvider = Provider<LeaderboardNotificationCoordinator>((ref) {
  final session = ref.watch(activeProfileSessionProvider);
  
  final orchestrator = ref.watch(notificationOrchestratorProvider);
  final coordinator = LeaderboardNotificationCoordinator(orchestrator);

  if (session != null) {
    final familyId = ref.watch(familyProvider).circle?.id;

    for (final type in [LeaderboardType.family, LeaderboardType.friends]) {
      for (final period in LeaderboardPeriod.values) {
        ref.listen<AsyncValue<Leaderboard?>>(
          currentLeaderboardProvider((type, period, familyId)),
          (previous, next) {
            final leaderboard = next.value;
            if (leaderboard != null) {
              final entry = leaderboard.entries.where((e) => e.profileId == session.profileId).firstOrNull;
              coordinator.processTransition(type, period, session.profileId, entry, familyId);
            }
          },
          fireImmediately: true,
        );
      }
    }
  }

  return coordinator;
});
