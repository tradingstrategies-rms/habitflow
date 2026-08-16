import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/billing/data/repositories/local_premium_telemetry_service.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late LocalPremiumTelemetryService service;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    service = LocalPremiumTelemetryService(mockPrefs);
  });

  group('LocalPremiumTelemetryService', () {
    test('recordEvent persists event', () async {
      when(() => mockPrefs.getStringList(any())).thenReturn([]);
      when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

      final event = PremiumTelemetryEvent(
        type: PremiumEventType.subscriptionScreenViewed,
        timestamp: DateTime(2024),
      );

      await service.recordEvent(event);

      verify(() => mockPrefs.setStringList('hf_premium_telemetry', any())).called(1);
    });

    test('getMetrics calculates correct aggregates', () async {
      final events = [
        PremiumTelemetryEvent(type: PremiumEventType.subscriptionScreenViewed, timestamp: DateTime(2024)),
        PremiumTelemetryEvent(type: PremiumEventType.subscriptionScreenViewed, timestamp: DateTime(2024)),
        PremiumTelemetryEvent(type: PremiumEventType.upgradeStarted, timestamp: DateTime(2024)),
        PremiumTelemetryEvent(type: PremiumEventType.purchaseSucceeded, timestamp: DateTime(2024)),
      ];

      final jsonList = events.map((e) => jsonEncode(e.toJson())).toList();
      when(() => mockPrefs.getStringList('hf_premium_telemetry')).thenReturn(jsonList);

      final metrics = await service.getMetrics();

      expect(metrics.subscriptionViews, 2);
      expect(metrics.upgradeAttempts, 1);
      expect(metrics.successfulPurchases, 1);
      expect(metrics.conversionRate, 0.5);
    });

    test('clear removes storage key', () async {
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      await service.clear();
      verify(() => mockPrefs.remove('hf_premium_telemetry')).called(1);
    });
  });
}
