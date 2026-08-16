import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/billing/application/providers/billing_providers.dart';
import 'package:habitflow/features/billing/domain/entities/purchase_result.dart';
import 'package:habitflow/features/billing/domain/repositories/billing_service.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBillingService extends Mock implements BillingService {}
class MockTelemetryService extends Mock implements PremiumTelemetryService {}

void main() {
  late MockBillingService mockBillingService;
  late MockTelemetryService mockTelemetryService;
  late PurchaseNotifier notifier;

  setUpAll(() {
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.upgradeStarted,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockBillingService = MockBillingService();
    mockTelemetryService = MockTelemetryService();
    notifier = PurchaseNotifier(
      mockBillingService,
      mockTelemetryService,
      () {},
    );

    when(() => mockTelemetryService.recordEvent(any())).thenAnswer((_) async => {});
  });

  group('PurchaseNotifier', () {
    test('purchase prevents duplicate calls while loading', () async {
      when(() => mockBillingService.purchase(any()))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return const PurchaseResult(status: PurchaseStatus.success);
          });

      // Start first purchase
      final first = notifier.purchase('p1');
      expect(notifier.state.isLoading, true);

      // Start second purchase immediately
      await notifier.purchase('p1');

      await first;
      
      // Verify billing service was only called once
      verify(() => mockBillingService.purchase(any())).called(1);
    });

    test('restorePurchases prevents duplicate calls while loading', () async {
      when(() => mockBillingService.restorePurchases())
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return const PurchaseResult(status: PurchaseStatus.success);
          });

      // Start first restore
      final first = notifier.restorePurchases();
      expect(notifier.state.isLoading, true);

      // Start second restore immediately
      await notifier.restorePurchases();

      await first;
      
      // Verify billing service was only called once
      verify(() => mockBillingService.restorePurchases()).called(1);
    });

    test('reset clears the state', () async {
      when(() => mockBillingService.purchase(any()))
          .thenAnswer((_) async => const PurchaseResult(status: PurchaseStatus.success));

      await notifier.purchase('p1');
      expect(notifier.state.hasValue, true);
      expect(notifier.state.value?.isSuccess, true);

      notifier.reset();
      expect(notifier.state.value, null);
    });
  });
}
