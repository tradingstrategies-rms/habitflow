import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/habits/application/services/quiet_hours_policy_service.dart';
import 'package:habitflow/features/habits/domain/entities/quiet_hours_settings.dart';
import 'package:habitflow/features/habits/domain/repositories/quiet_hours_repository.dart';

class MockQuietHoursRepository extends Mock implements QuietHoursRepository {}

void main() {
  late MockQuietHoursRepository repository;
  late QuietHoursPolicyService service;

  setUp(() {
    repository = MockQuietHoursRepository();
    service = QuietHoursPolicyService(repository);
  });

  group('QuietHoursPolicyService', () {
    test('isWithinQuietHours returns false when disabled', () async {
      when(() => repository.getSettings()).thenAnswer((_) async => QuietHoursSettings.initial());
      
      final result = await service.isWithinQuietHours(DateTime(2023, 1, 1, 23, 0));
      expect(result, false);
    });

    test('isWithinQuietHours handles same-day windows', () async {
      const settings = QuietHoursSettings(
        enabled: true,
        startTime: TimeOfDay(hour: 13, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 0),
      );
      when(() => repository.getSettings()).thenAnswer((_) async => settings);
      
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 14, 0)), true);
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 12, 0)), false);
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 16, 0)), false);
    });

    test('isWithinQuietHours handles cross-midnight windows', () async {
      const settings = QuietHoursSettings(
        enabled: true,
        startTime: TimeOfDay(hour: 22, minute: 0),
        endTime: TimeOfDay(hour: 8, minute: 0),
      );
      when(() => repository.getSettings()).thenAnswer((_) async => settings);
      
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 23, 0)), true);
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 7, 0)), true);
      expect(await service.isWithinQuietHours(DateTime(2023, 1, 1, 12, 0)), false);
    });

    test('nextAllowedTime returns next morning for cross-midnight window', () async {
       const settings = QuietHoursSettings(
        enabled: true,
        startTime: TimeOfDay(hour: 22, minute: 0),
        endTime: TimeOfDay(hour: 8, minute: 0),
      );
      when(() => repository.getSettings()).thenAnswer((_) async => settings);

      final input = DateTime(2023, 1, 1, 23, 0); // Sunday 11 PM
      final result = await service.nextAllowedTime(input);
      
      expect(result.year, 2023);
      expect(result.month, 1);
      expect(result.day, 2); // Monday
      expect(result.hour, 8);
      expect(result.minute, 0);
    });
  });
}
