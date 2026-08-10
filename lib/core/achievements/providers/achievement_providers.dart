import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_controller.dart';
import '../events/goal_completed_event.dart';
import '../services/achievement_event_bus.dart';

/// Provider for [AchievementEventBus].
final achievementEventBusProvider = Provider<AchievementEventBus>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final bus = AchievementEventBus(prefs);
  ref.onDispose(() => bus.dispose());
  return bus;
});

/// StreamProvider for [GoalCompletedEvent]s.
final goalCompletionEventsProvider = StreamProvider<GoalCompletedEvent>((ref) {
  final bus = ref.watch(achievementEventBusProvider);
  return bus.onGoalCompleted;
});
