import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';

void main() {
  group('PremiumService', () {
    test('isPremium should reflect subscription status', () {
      final freeService = PremiumService(Subscription.free());
      expect(freeService.isPremium, isFalse);

      final premiumService = PremiumService(const Subscription(
        id: '1',
        status: SubscriptionStatus.premium,
      ));
      expect(premiumService.isPremium, isTrue);
    });

    test('hasEntitlement should return true for premium user', () {
      final service = PremiumService(const Subscription(
        id: '1',
        status: SubscriptionStatus.premium,
      ));
      expect(service.hasEntitlement(EntitlementType.advancedAnalytics), isTrue);
      expect(service.hasEntitlement(EntitlementType.premiumRewards), isTrue);
    });

    test('hasEntitlement should check specific entitlements for non-premium user', () {
      final service = PremiumService(const Subscription(
        id: '1',
        status: SubscriptionStatus.free,
        entitlements: ['advancedAnalytics'],
      ));
      expect(service.hasEntitlement(EntitlementType.advancedAnalytics), isTrue);
      expect(service.hasEntitlement(EntitlementType.premiumRewards), isFalse);
    });

    test('hasEntitlement should return false for free user with no entitlements', () {
      final service = PremiumService(Subscription.free());
      expect(service.hasEntitlement(EntitlementType.advancedAnalytics), isFalse);
    });
  });
}
