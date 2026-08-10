import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_reminder.dart';
import 'habit_repository_provider.dart';

/// Provider that fetches all habit reminders.
final allRemindersProvider = FutureProvider<List<HabitReminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getReminders();
});

/// Provider that fetches the reminder for a specific habit.
final habitReminderProvider = FutureProvider.family<HabitReminder?, String>((ref, habitId) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getReminder(habitId);
});
