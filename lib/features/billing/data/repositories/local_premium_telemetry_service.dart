import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/premium_conversion_metrics.dart';
import '../../domain/entities/premium_event_type.dart';
import '../../domain/entities/premium_telemetry_event.dart';
import '../../domain/repositories/premium_telemetry_service.dart';

class LocalPremiumTelemetryService implements PremiumTelemetryService {
  final SharedPreferences _prefs;
  static const String _storageKey = 'hf_premium_telemetry';

  LocalPremiumTelemetryService(this._prefs);

  @override
  Future<void> recordEvent(PremiumTelemetryEvent event) async {
    final events = await getEvents();
    events.add(event);
    final jsonList = events.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }

  @override
  Future<List<PremiumTelemetryEvent>> getEvents() async {
    final jsonList = _prefs.getStringList(_storageKey);
    if (jsonList == null) return [];
    return jsonList.map((j) => PremiumTelemetryEvent.fromJson(jsonDecode(j))).toList();
  }

  @override
  Future<PremiumConversionMetrics> getMetrics() async {
    final events = await getEvents();
    
    int views = 0;
    int upgrades = 0;
    int success = 0;
    int cancelled = 0;
    int failed = 0;
    int restores = 0;
    int activations = 0;

    for (final event in events) {
      switch (event.type) {
        case PremiumEventType.subscriptionScreenViewed:
          views++;
          break;
        case PremiumEventType.upgradeStarted:
          upgrades++;
          break;
        case PremiumEventType.purchaseSucceeded:
          success++;
          break;
        case PremiumEventType.purchaseCancelled:
          cancelled++;
          break;
        case PremiumEventType.purchaseFailed:
          failed++;
          break;
        case PremiumEventType.restoreStarted:
          restores++;
          break;
        case PremiumEventType.premiumActivated:
          activations++;
          break;
        default:
          break;
      }
    }

    return PremiumConversionMetrics(
      subscriptionViews: views,
      upgradeAttempts: upgrades,
      successfulPurchases: success,
      cancelledPurchases: cancelled,
      failedPurchases: failed,
      restoreAttempts: restores,
      premiumActivations: activations,
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }
}
