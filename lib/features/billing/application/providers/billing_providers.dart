import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import '../../data/repositories/mock_billing_service.dart';
import '../../domain/entities/billing_product.dart';
import '../../domain/entities/purchase_result.dart';
import '../../domain/repositories/billing_service.dart';
import '../../domain/entities/premium_event_type.dart';
import '../../domain/entities/premium_telemetry_event.dart';
import '../../domain/repositories/premium_telemetry_service.dart';
import 'telemetry_providers.dart';

final billingServiceProvider = Provider<BillingService>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  return MockBillingService(subscriptionRepository);
});

final availableProductsProvider = FutureProvider<List<BillingProduct>>((ref) async {
  return ref.watch(billingServiceProvider).getProducts();
});

class PurchaseNotifier extends StateNotifier<AsyncValue<PurchaseResult?>> {
  final BillingService _billingService;
  final PremiumTelemetryService _telemetryService;
  final void Function() _onTelemetryUpdated;

  PurchaseNotifier(
    this._billingService,
    this._telemetryService,
    this._onTelemetryUpdated,
  ) : super(const AsyncValue.data(null));

  Future<void> purchase(String productId) async {
    if (state.isLoading) return;
    
    state = const AsyncValue.loading();
    
    await _telemetryService.recordEvent(PremiumTelemetryEvent(
      type: PremiumEventType.upgradeStarted,
      timestamp: DateTime.now(),
      source: productId,
    ));
    _onTelemetryUpdated();

    try {
      final result = await _billingService.purchase(productId);
      
      PremiumEventType eventType;
      switch (result.status) {
        case PurchaseStatus.success:
          eventType = PremiumEventType.purchaseSucceeded;
          await _telemetryService.recordEvent(PremiumTelemetryEvent(
            type: PremiumEventType.premiumActivated,
            timestamp: DateTime.now(),
          ));
          break;
        case PurchaseStatus.cancelled:
          eventType = PremiumEventType.purchaseCancelled;
          break;
        case PurchaseStatus.error:
          eventType = PremiumEventType.purchaseFailed;
          break;
        case PurchaseStatus.alreadyOwned:
          eventType = PremiumEventType.purchaseSucceeded;
          break;
        default:
          eventType = PremiumEventType.purchaseFailed;
      }

      await _telemetryService.recordEvent(PremiumTelemetryEvent(
        type: eventType,
        timestamp: DateTime.now(),
      ));
      _onTelemetryUpdated();

      state = AsyncValue.data(result);
    } catch (e, stack) {
      await _telemetryService.recordEvent(PremiumTelemetryEvent(
        type: PremiumEventType.purchaseFailed,
        timestamp: DateTime.now(),
      ));
      _onTelemetryUpdated();
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restorePurchases() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    await _telemetryService.recordEvent(PremiumTelemetryEvent(
      type: PremiumEventType.restoreStarted,
      timestamp: DateTime.now(),
    ));
    _onTelemetryUpdated();

    try {
      final result = await _billingService.restorePurchases();
      
      PremiumEventType eventType;
      if (result.isSuccess || result.isAlreadyOwned) {
        eventType = PremiumEventType.restoreSucceeded;
        await _telemetryService.recordEvent(PremiumTelemetryEvent(
          type: PremiumEventType.premiumActivated,
          timestamp: DateTime.now(),
        ));
      } else {
        eventType = PremiumEventType.restoreFailed;
      }

      await _telemetryService.recordEvent(PremiumTelemetryEvent(
        type: eventType,
        timestamp: DateTime.now(),
      ));
      _onTelemetryUpdated();

      state = AsyncValue.data(result);
    } catch (e, stack) {
      await _telemetryService.recordEvent(PremiumTelemetryEvent(
        type: PremiumEventType.restoreFailed,
        timestamp: DateTime.now(),
      ));
      _onTelemetryUpdated();
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final purchaseStateProvider = StateNotifierProvider<PurchaseNotifier, AsyncValue<PurchaseResult?>>((ref) {
  final billingService = ref.watch(billingServiceProvider);
  final telemetryService = ref.watch(premiumTelemetryServiceProvider);
  return PurchaseNotifier(
    billingService,
    telemetryService,
    () => ref.invalidate(premiumConversionMetricsProvider),
  );
});
