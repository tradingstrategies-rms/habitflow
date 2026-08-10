import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/habits/domain/entities/habit_reminder.dart';
import 'package:habitflow/features/habits/infrastructure/repositories/local_reminder_repository.dart';

void main() {
  late SharedPreferences prefs;
  late LocalReminderRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = LocalReminderRepository(prefs);
  });

  group('LocalReminderRepository', () {
    final reminder = HabitReminder(
      id: 'r1',
      habitId: 'h1',
      enabled: true,
      timeOfDay: const TimeOfDay(hour: 9, minute: 0),
      weekdays: const [1, 2, 3, 4, 5],
      repeatType: ReminderRepeatType.daily,
      notificationTitle: 'Title',
      notificationBody: 'Body',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('getReminders returns empty list initially', () async {
      final result = await repository.getReminders();
      expect(result, isEmpty);
    });

    test('saveReminder and getReminder work', () async {
      await repository.saveReminder(reminder);
      
      final result = await repository.getReminder('h1');
      expect(result, equals(reminder));
    });

    test('update existing reminder works', () async {
      await repository.saveReminder(reminder);
      final updated = reminder.copyWith(enabled: false);
      await repository.saveReminder(updated);

      final result = await repository.getReminder('h1');
      expect(result?.enabled, false);
    });

    test('deleteReminder works', () async {
      await repository.saveReminder(reminder);
      await repository.deleteReminder('h1');

      final result = await repository.getReminder('h1');
      expect(result, isNull);
    });
  });
}
