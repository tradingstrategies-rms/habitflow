import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/habits/application/services/reminder_scheduler_service.dart';
import 'package:habitflow/features/habits/application/services/quiet_hours_policy_service.dart';
import 'package:habitflow/features/habits/application/services/notification_router_service.dart';
import 'package:habitflow/features/habits/domain/entities/habit_reminder.dart';
import 'package:habitflow/features/habits/domain/repositories/reminder_repository.dart';
import 'package:habitflow/features/habits/infrastructure/notifications/local_notification_adapter.dart';

class MockNotificationAdapter extends Mock implements LocalNotificationAdapter {}
class MockReminderRepository extends Mock implements ReminderRepository {}
class MockQuietHoursPolicy extends Mock implements QuietHoursPolicyService {}
class MockNotificationRouter extends Mock implements NotificationRouterService {}

void main() {
  late MockNotificationAdapter adapter;
  late MockReminderRepository repository;
  late MockQuietHoursPolicy quietHoursPolicy;
  late MockNotificationRouter notificationRouter;
  late ReminderSchedulerService service;

  setUp(() {
    adapter = MockNotificationAdapter();
    repository = MockReminderRepository();
    quietHoursPolicy = MockQuietHoursPolicy();
    notificationRouter = MockNotificationRouter();
    service = ReminderSchedulerService(adapter, repository, quietHoursPolicy, notificationRouter);

    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
    
    // Default: no quiet hours delay
    when(() => quietHoursPolicy.nextAllowedTime(any())).thenAnswer((inv) async => inv.positionalArguments[0] as DateTime);
  });

  group('ReminderSchedulerService', () {
    final reminder = HabitReminder(
      id: 'r1',
      habitId: 'h1',
      enabled: true,
      timeOfDay: const TimeOfDay(hour: 9, minute: 0),
      weekdays: const [1, 3, 5],
      repeatType: ReminderRepeatType.selectedWeekdays,
      notificationTitle: 'Habit!',
      notificationBody: 'Do it.',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('scheduleReminder daily calls scheduleDaily', () async {
      final dailyReminder = reminder.copyWith(repeatType: ReminderRepeatType.daily);
      
      when(() => adapter.scheduleDaily(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: any(named: 'time'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});

      await service.scheduleReminder(dailyReminder);

      verify(() => adapter.scheduleDaily(
        id: any(named: 'id'),
        title: 'Habit!',
        body: 'Do it.',
        time: const TimeOfDay(hour: 9, minute: 0),
        payload: any(named: 'payload'),
      )).called(1);
    });

    test('scheduleReminder weekly calls scheduleWeekly for each day', () async {
       when(() => adapter.scheduleWeekly(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: any(named: 'time'),
        weekday: any(named: 'weekday'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});
      
      when(() => adapter.cancel(any())).thenAnswer((_) async {});

      await service.scheduleReminder(reminder);

      verify(() => adapter.scheduleWeekly(
        id: any(named: 'id'),
        title: 'Habit!',
        body: 'Do it.',
        time: const TimeOfDay(hour: 9, minute: 0),
        weekday: any(named: 'weekday'),
        payload: any(named: 'payload'),
      )).called(3);
    });

    test('scheduleReminder ignores disabled reminders', () async {
      final disabled = reminder.copyWith(enabled: false);
      when(() => adapter.cancel(any())).thenAnswer((_) async {});

      await service.scheduleReminder(disabled);

      verify(() => adapter.cancel(any())).called(greaterThan(0));
      verifyNever(() => adapter.scheduleWeekly(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: any(named: 'time'),
        weekday: any(named: 'weekday'),
      ));
    });

    test('scheduleReminder applies quiet hours delay', () async {
      final dailyReminder = reminder.copyWith(repeatType: ReminderRepeatType.daily);
      final delayedTime = DateTime.now().add(const Duration(hours: 2));
      
      when(() => quietHoursPolicy.nextAllowedTime(any())).thenAnswer((_) async => delayedTime);
      when(() => adapter.scheduleDaily(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: any(named: 'time'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});

      await service.scheduleReminder(dailyReminder);

      verify(() => adapter.scheduleDaily(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: TimeOfDay.fromDateTime(delayedTime),
        payload: any(named: 'payload'),
      )).called(1);
    });

    test('scheduleReminder once calls scheduleOnce', () async {
      final onceReminder = reminder.copyWith(repeatType: ReminderRepeatType.once);
      
      when(() => adapter.scheduleOnce(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: any(named: 'time'),
        payload: any(named: 'payload'),
      )).thenAnswer((_) async {});

      await service.scheduleReminder(onceReminder);

      verify(() => adapter.scheduleOnce(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        time: const TimeOfDay(hour: 9, minute: 0),
        payload: any(named: 'payload'),
      )).called(1);
    });
  });
}
