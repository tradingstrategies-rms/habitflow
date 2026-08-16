import 'package:flutter/foundation.dart';

@immutable
class PremiumConversionMetrics {
  final int subscriptionViews;
  final int upgradeAttempts;
  final int successfulPurchases;
  final int cancelledPurchases;
  final int failedPurchases;
  final int restoreAttempts;
  final int premiumActivations;

  const PremiumConversionMetrics({
    required this.subscriptionViews,
    required this.upgradeAttempts,
    required this.successfulPurchases,
    required this.cancelledPurchases,
    required this.failedPurchases,
    required this.restoreAttempts,
    required this.premiumActivations,
  });

  double get conversionRate {
    if (subscriptionViews == 0) return 0.0;
    return successfulPurchases / subscriptionViews;
  }

  factory PremiumConversionMetrics.empty() {
    return const PremiumConversionMetrics(
      subscriptionViews: 0,
      upgradeAttempts: 0,
      successfulPurchases: 0,
      cancelledPurchases: 0,
      failedPurchases: 0,
      restoreAttempts: 0,
      premiumActivations: 0,
    );
  }
}
