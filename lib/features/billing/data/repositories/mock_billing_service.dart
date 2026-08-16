import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/domain/repositories/subscription_repository.dart';
import '../../domain/entities/billing_product.dart';
import '../../domain/entities/purchase_result.dart';
import '../../domain/repositories/billing_service.dart';

class MockBillingService implements BillingService {
  final SubscriptionRepository _subscriptionRepository;

  MockBillingService(this._subscriptionRepository);

  static const String premiumProductId = 'hf_premium_monthly';

  @override
  Future<List<BillingProduct>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const [
      BillingProduct(
        id: premiumProductId,
        name: 'HabitFlow Premium',
        description: 'Unlock all advanced features and AI insights.',
        price: 4.99,
        currencyCode: 'USD',
        formattedPrice: '\$4.99/mo',
      ),
    ];
  }

  @override
  Future<PurchaseResult> purchase(String productId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (productId.contains('cancel')) {
       return const PurchaseResult(status: PurchaseStatus.cancelled);
    }
    if (productId.contains('fail')) {
       return const PurchaseResult(status: PurchaseStatus.error, errorMessage: 'Simulated payment failure');
    }

    if (productId != premiumProductId) {
      return const PurchaseResult(
        status: PurchaseStatus.error,
        errorMessage: 'Product not found',
      );
    }

    final current = await _subscriptionRepository.getSubscription();
    if (current.isPremium) {
      return const PurchaseResult(status: PurchaseStatus.alreadyOwned);
    }

    final newSubscription = Subscription(
      id: 'mock_premium_id',
      status: SubscriptionStatus.premium,
      productId: premiumProductId,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      entitlements: EntitlementType.values.map((e) => e.name).toList(),
    );

    await _subscriptionRepository.setSubscription(newSubscription);

    return const PurchaseResult(status: PurchaseStatus.success);
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final current = await _subscriptionRepository.getSubscription();
    if (current.isPremium) {
      return const PurchaseResult(status: PurchaseStatus.alreadyOwned);
    }

    final restoredSubscription = Subscription(
      id: 'restored_premium_id',
      status: SubscriptionStatus.premium,
      productId: premiumProductId,
      expiresAt: DateTime.now().add(const Duration(days: 15)),
      entitlements: EntitlementType.values.map((e) => e.name).toList(),
    );

    await _subscriptionRepository.setSubscription(restoredSubscription);

    return const PurchaseResult(status: PurchaseStatus.success);
  }
}
