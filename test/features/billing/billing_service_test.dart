import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:habitflow/features/billing/data/repositories/mock_billing_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository mockSubscriptionRepository;
  late MockBillingService billingService;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
    billingService = MockBillingService(mockSubscriptionRepository);
    
    registerFallbackValue(Subscription.free());
  });

  group('MockBillingService', () {
    test('getProducts returns premium product', () async {
      final products = await billingService.getProducts();
      expect(products, isNotEmpty);
      expect(products.first.id, MockBillingService.premiumProductId);
    });

    test('purchase succeeds and updates repository', () async {
      when(() => mockSubscriptionRepository.getSubscription())
          .thenAnswer((_) async => Subscription.free());
      when(() => mockSubscriptionRepository.setSubscription(any()))
          .thenAnswer((_) async => {});

      final result = await billingService.purchase(MockBillingService.premiumProductId);

      expect(result.isSuccess, true);
      verify(() => mockSubscriptionRepository.setSubscription(any())).called(1);
    });

    test('purchase fails for invalid product', () async {
      final result = await billingService.purchase('invalid_id');
      expect(result.isError, true);
      expect(result.errorMessage, 'Product not found');
    });

    test('restorePurchases updates repository', () async {
      when(() => mockSubscriptionRepository.getSubscription())
          .thenAnswer((_) async => Subscription.free());
      when(() => mockSubscriptionRepository.setSubscription(any()))
          .thenAnswer((_) async => {});

      final result = await billingService.restorePurchases();

      expect(result.isSuccess, true);
      verify(() => mockSubscriptionRepository.setSubscription(any())).called(1);
    });

    test('purchase returns cancelled if productId contains cancel', () async {
      when(() => mockSubscriptionRepository.getSubscription())
          .thenAnswer((_) async => Subscription.free());
      
      final result = await billingService.purchase('cancel_me');
      expect(result.isCancelled, true);
    });

    test('purchase returns error if productId contains fail', () async {
      when(() => mockSubscriptionRepository.getSubscription())
          .thenAnswer((_) async => Subscription.free());
      
      final result = await billingService.purchase('fail_me');
      expect(result.isError, true);
      expect(result.errorMessage, 'Simulated payment failure');
    });
  });
}
