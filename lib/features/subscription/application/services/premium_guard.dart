import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';

/// A mixin to be used by widgets that need to guard features behind premium.
mixin PremiumGuard {
  bool checkPremium(WidgetRef ref) {
    return ref.read(premiumServiceProvider).isPremium;
  }

  bool checkEntitlement(WidgetRef ref, EntitlementType entitlement) {
    return ref.read(premiumServiceProvider).hasEntitlement(entitlement);
  }

  /// Foundation for future UI gating.
  /// In a real app, this could show a paywall dialog.
  void guardFeature(BuildContext context, WidgetRef ref, {EntitlementType? entitlement}) {
    final hasAccess = entitlement != null
        ? checkEntitlement(ref, entitlement)
        : checkPremium(ref);

    if (!hasAccess) {
      _showPremiumRequiredMessage(context);
    }
  }

  void _showPremiumRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium subscription required to access this feature.'),
      ),
    );
  }
}
