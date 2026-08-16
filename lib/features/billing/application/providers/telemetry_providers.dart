import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../data/repositories/local_premium_telemetry_service.dart';
import '../../domain/entities/premium_conversion_metrics.dart';
import '../../domain/entities/premium_telemetry_event.dart';
import '../../domain/repositories/premium_telemetry_service.dart';

final premiumTelemetryServiceProvider = Provider<PremiumTelemetryService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalPremiumTelemetryService(prefs);
});

final premiumConversionMetricsProvider = FutureProvider<PremiumConversionMetrics>((ref) async {
  return ref.watch(premiumTelemetryServiceProvider).getMetrics();
});

extension TelemetryRefX on Ref {
  Future<void> recordPremiumEvent(PremiumTelemetryEvent event) async {
    await read(premiumTelemetryServiceProvider).recordEvent(event);
    invalidate(premiumConversionMetricsProvider);
  }
}

extension TelemetryWidgetRefX on WidgetRef {
  Future<void> recordPremiumEvent(PremiumTelemetryEvent event) async {
    await read(premiumTelemetryServiceProvider).recordEvent(event);
    invalidate(premiumConversionMetricsProvider);
  }
}
