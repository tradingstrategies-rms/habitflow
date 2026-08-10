import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/missed_habit_repository.dart';
import '../../infrastructure/repositories/local_missed_habit_repository.dart';
import '../services/missed_habit_detection_service.dart';
import 'habit_repository_provider.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

/// Provider for [MissedHabitRepository].
final missedHabitRepositoryProvider = Provider<MissedHabitRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalMissedHabitRepository(prefs);
});

/// Provider for [MissedHabitDetectionService].
final missedHabitDetectionServiceProvider = Provider<MissedHabitDetectionService>((ref) {
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final completionRepo = ref.watch(habitCompletionRepositoryProvider);
  final missedRepo = ref.watch(missedHabitRepositoryProvider);

  return MissedHabitDetectionService(
    reminderRepository: reminderRepo,
    completionRepository: completionRepo,
    missedHabitRepository: missedRepo,
  );
});

/// Provider for list of missed habit events.
final missedHabitEventsProvider = FutureProvider((ref) {
  return ref.watch(missedHabitRepositoryProvider).getEvents();
});
