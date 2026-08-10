import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/habit_reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/habit_reminder_model.dart';

/// [LocalReminderRepository] implements [ReminderRepository] using SharedPreferences.
/// It provides persistence for habit reminders without any scheduling logic.
class LocalReminderRepository implements ReminderRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'habitflow_reminders_v1';

  /// Creates a [LocalReminderRepository].
  LocalReminderRepository(this._prefs);

  @override
  Future<List<HabitReminder>> getReminders() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => HabitReminderModel.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<HabitReminder?> getReminder(String habitId) async {
    final reminders = await getReminders();
    for (final reminder in reminders) {
      if (reminder.habitId == habitId) return reminder;
    }
    return null;
  }

  @override
  Future<void> saveReminder(HabitReminder reminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((r) => r.habitId == reminder.habitId);

    if (index != -1) {
      reminders[index] = reminder;
    } else {
      reminders.add(reminder);
    }

    await _saveAll(reminders);
  }

  @override
  Future<void> deleteReminder(String habitId) async {
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.habitId == habitId);
    await _saveAll(reminders);
  }

  /// Persists the entire list of reminders to storage.
  Future<void> _saveAll(List<HabitReminder> reminders) async {
    final jsonString = json.encode(
      reminders.map((r) => HabitReminderModel.fromEntity(r).toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }
}
