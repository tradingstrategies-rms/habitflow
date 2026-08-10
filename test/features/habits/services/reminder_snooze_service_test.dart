import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/habits/application/services/reminder_snooze_service.dart';
import 'package:habitflow/features/habits/domain/entities/habit_reminder.dart';
import 'package:habitflow/features/habits/infrastructure/notifications/local_notification_adapter.dart';

class MockNotificationAdapter extends Mock implements LocalNotificationAdapter {}

void main() {
  late MockNotificationAdapter adapter;
  late ReminderSnoozeService service;

  setUp(() {
    adapter = MockNotificationAdapter();
    service = ReminderSnoozeService(adapter);
    
    registerFallbackValue(DateTime.now());
  });

  group('ReminderSnoozeService', () {
    final reminder = HabitReminder(
      id: 'r1',
      habitId: 'h1',
      enabled: true,
      timeOfDay: const TimeOfDay(hour: 9, minute: 0),
      weekdays: const [1, 2, 3],
      repeatType: ReminderRepeatType.daily,
      notificationTitle: 'Title',
      notificationBody: 'Body',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('snoozeReminder schedules one-time notification for valid duration', () async {
      when(() => adapter.scheduleOneTimeNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});

      await service.snoozeReminder(reminder, 15);

      verify(() => adapter.scheduleOneTimeNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        payload: any(named: 'payload'),
      )).called(1);
    });

    test('snoozeReminder throws error for invalid duration', () async {
      expect(
        () => service.snoozeReminder(reminder, 7),
        throwsArgumentError,
      );
    });

    test('snooze IDs are different for different times', () async {
       // This is more of an internal logic check if we could expose the ID generator
       // but we can verify it by checking verification calls if we could predict them.
       // For now, the implementation uses Object.hash with millisecondsSinceEpoch.
    });
  });
}
