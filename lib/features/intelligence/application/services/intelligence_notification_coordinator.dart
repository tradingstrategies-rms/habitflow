import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_priority.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/router/route_paths.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';

/// [IntelligenceNotificationCoordinator] handles intelligence engagement logic.
class IntelligenceNotificationCoordinator {
  final NotificationOrchestrator _orchestrator;
  final Set<String> _notifiedIds = {};

  IntelligenceNotificationCoordinator(this._orchestrator);

  void processSummary(IntelligenceDashboardSummary summary, String profileId) {
    final priorityInsight = summary.priorityInsight;
    if (priorityInsight != null) {
      _evaluateInsight(priorityInsight, profileId);
    }

    for (final insight in summary.otherInsights) {
      _evaluateInsight(insight, profileId);
    }
  }

  void _evaluateInsight(HabitInsight insight, String profileId) {
    if (!_isEligible(insight)) return;

    final stableId = 'intelligence_${insight.category.name}_${profileId}_${insight.habitId}';

    if (_notifiedIds.contains(stableId)) return;
    _notifiedIds.add(stableId);

    _triggerNotification(insight, stableId, profileId);
  }

  bool _isEligible(HabitInsight insight) {
    if (insight.severity == InsightSeverity.high) return true;
    
    if (insight.category == InsightCategory.warning && 
        (insight.title.contains('Fading') || insight.title.contains('Consistency'))) {
      return true;
    }

    if (insight.category == InsightCategory.recovery || 
        insight.category == InsightCategory.trend) {
      return insight.severity != InsightSeverity.low;
    }

    return false;
  }

  Future<void> _triggerNotification(
    HabitInsight insight, 
    String stableId,
    String profileId,
  ) async {
    final payload = NotificationPayload(
      id: stableId,
      title: insight.title,
      body: insight.summary,
      type: NotificationType.intelligence,
      priority: _mapSeverityToPriority(insight.severity),
      route: RoutePaths.intelligence,
      recipientProfileId: profileId,
    );

    await _orchestrator.notify(payload);
  }

  NotificationPriority _mapSeverityToPriority(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.high:
        return NotificationPriority.high;
      case InsightSeverity.medium:
        return NotificationPriority.normal;
      case InsightSeverity.low:
        return NotificationPriority.low;
    }
  }
}

/// Provider for Intelligence engagement notifications.
final intelligenceNotificationCoordinatorProvider = Provider<IntelligenceNotificationCoordinator>((ref) {
  // Rebuild when session changes to ensure fresh state for new profile
  final session = ref.watch(activeProfileSessionProvider);
  
  final orchestrator = ref.watch(notificationOrchestratorProvider);
  final coordinator = IntelligenceNotificationCoordinator(orchestrator);

  if (session != null) {
    ref.listen<AsyncValue<IntelligenceDashboardSummary?>>(
      intelligenceDashboardProvider,
      (previous, next) {
        final summary = next.value;
        if (summary != null) {
          coordinator.processSummary(summary, session.profileId);
        }
      },
      fireImmediately: true,
    );
  }

  return coordinator;
});
