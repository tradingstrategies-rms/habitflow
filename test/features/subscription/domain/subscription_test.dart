import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';

void main() {
  group('Subscription Entity', () {
    test('Subscription.free() should return a free subscription', () {
      final sub = Subscription.free();
      expect(sub.status, SubscriptionStatus.free);
      expect(sub.isPremium, isFalse);
      expect(sub.entitlements, isEmpty);
    });

    test('isPremium should return true if status is premium and not expired', () {
      final sub = Subscription(
        id: '1',
        status: SubscriptionStatus.premium,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isPremium, isTrue);
    });

    test('isPremium should return false if status is premium but expired', () {
      final sub = Subscription(
        id: '1',
        status: SubscriptionStatus.premium,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isPremium, isFalse);
    });

    test('isPremium should return true if status is premium and expiresAt is null', () {
      const sub = Subscription(
        id: '1',
        status: SubscriptionStatus.premium,
      );
      expect(sub.isPremium, isTrue);
    });
  });
}
