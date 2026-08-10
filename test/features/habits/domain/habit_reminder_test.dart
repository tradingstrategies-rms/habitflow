import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/habits/domain/entities/habit_reminder.dart';

void main() {
  group('HabitReminder', () {
    final reminder = HabitReminder(
      id: '1',
      habitId: 'habit1',
      enabled: true,
      timeOfDay: const TimeOfDay(hour: 8, minute: 30),
      weekdays: const [1, 2, 3],
      repeatType: ReminderRepeatType.selectedWeekdays,
      notificationTitle: 'Title',
      notificationBody: 'Body',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('equality works', () {
      final same = reminder.copyWith();
      expect(reminder, equals(same));
      expect(reminder.hashCode, equals(same.hashCode));

      final different = reminder.copyWith(id: '2');
      expect(reminder, isNot(equals(different)));
    });

    test('copyWith works', () {
      final updated = reminder.copyWith(enabled: false);
      expect(updated.enabled, false);
      expect(updated.id, reminder.id);
    });
  });
}
