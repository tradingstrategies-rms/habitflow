import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/habits/application/services/missed_habit_detection_service.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/domain/entities/habit_reminder.dart';
import 'package:habitflow/features/habits/domain/entities/missed_habit_event.dart';
import 'package:habitflow/features/habits/domain/repositories/reminder_repository.dart';
import 'package:habitflow/features/habits/domain/repositories/habit_completion_repository.dart';
import 'package:habitflow/features/habits/domain/repositories/missed_habit_repository.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}
class MockHabitCompletionRepository extends Mock implements HabitCompletionRepository {}
class MockMissedHabitRepository extends Mock implements MissedHabitRepository {}

void main() {
  late MockReminderRepository reminderRepo;
  late MockHabitCompletionRepository completionRepo;
  late MockMissedHabitRepository missedRepo;
  late MissedHabitDetectionService service;

  setUp(() {
    reminderRepo = MockReminderRepository();
    completionRepo = MockHabitCompletionRepository();
    missedRepo = MockMissedHabitRepository();
    service = MissedHabitDetectionService(
      reminderRepository: reminderRepo,
      completionRepository: completionRepo,
      missedHabitRepository: missedRepo,
    );
    
    registerFallbackValue(MissedHabitEvent(
      habitId: '',
      reminderId: '',
      scheduledTime: DateTime(2023),
      detectedAt: DateTime(2023),
    ));
  });

  group('MissedHabitDetectionService', () {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(minutes: 61));
    
    final reminder = HabitReminder(
      id: 'r1',
      habitId: 'h1',
      enabled: true,
      timeOfDay: TimeOfDay(hour: oneHourAgo.hour, minute: oneHourAgo.minute),
      weekdays: const [1, 2, 3, 4, 5, 6, 7],
      repeatType: ReminderRepeatType.daily,
      notificationTitle: 'Title',
      notificationBody: 'Body',
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now,
    );

    test('detectMissedHabits creates event when habit was missed', () async {
      when(() => reminderRepo.getReminders()).thenAnswer((_) async => [reminder]);
      when(() => completionRepo.getCompletionsForHabit('h1')).thenAnswer((_) async => []);
      when(() => missedRepo.saveEvent(any())).thenAnswer((_) async {});

      await service.detectMissedHabits();

      verify(() => missedRepo.saveEvent(any(that: predicate<MissedHabitEvent>((e) => e.habitId == 'h1')))).called(1);
    });

    test('detectMissedHabits creates no event when habit was completed', () async {
       final completion = HabitCompletion(
        id: 'c1',
        habitId: 'h1',
        completionDate: oneHourAgo,
        completed: true,
        completedAt: oneHourAgo.add(const Duration(minutes: 5)),
        createdAt: oneHourAgo,
      );
      
      when(() => reminderRepo.getReminders()).thenAnswer((_) async => [reminder]);
      when(() => completionRepo.getCompletionsForHabit('h1')).thenAnswer((_) async => [completion]);
      
      await service.detectMissedHabits();

      verifyNever(() => missedRepo.saveEvent(any()));
    });

    test('detectMissedHabits respects grace period', () async {
      final recentReminder = reminder.copyWith(
        timeOfDay: TimeOfDay.fromDateTime(now.subtract(const Duration(minutes: 30))),
      );
      when(() => reminderRepo.getReminders()).thenAnswer((_) async => [recentReminder]);
      
      await service.detectMissedHabits();

      verifyNever(() => missedRepo.saveEvent(any()));
    });
  });
}
