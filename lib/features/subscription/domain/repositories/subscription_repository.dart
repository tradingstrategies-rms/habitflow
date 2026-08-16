import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription> getSubscription();
  Future<void> setSubscription(Subscription subscription);
  Future<void> resetSubscription();
  Stream<Subscription> watchSubscription();
}
