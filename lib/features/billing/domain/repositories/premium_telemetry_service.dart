import '../entities/premium_telemetry_event.dart';
import '../entities/premium_conversion_metrics.dart';

abstract class PremiumTelemetryService {
  Future<void> recordEvent(PremiumTelemetryEvent event);
  Future<List<PremiumTelemetryEvent>> getEvents();
  Future<PremiumConversionMetrics> getMetrics();
  Future<void> clear();
}
