import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/home/presentation/widgets/intelligence_preview_card.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockTelemetryService extends Mock implements PremiumTelemetryService {}

void main() {
  setUpAll(() {
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.subscriptionScreenViewed,
      timestamp: DateTime.now(),
    ));
  });

  testWidgets('IntelligencePreviewCard renders loading state', (WidgetTester tester) async {
    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);

    final mockTelemetry = MockTelemetryService();
    when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});
    when(() => mockTelemetry.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          premiumServiceProvider.overrideWithValue(PremiumService(Subscription.free())),
          intelligenceSummaryProvider.overrideWith((ref) => Future.value(null)),
          intelligenceDashboardProvider.overrideWith((ref) => Completer<IntelligenceDashboardSummary?>().future),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: IntelligencePreviewCard(onTap: () {}),
          ),
        ),
      ),
    );

    // Initial state might be loading, then null data
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
