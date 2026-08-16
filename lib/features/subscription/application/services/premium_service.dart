import '../../domain/entities/subscription.dart';
import '../../domain/enums/entitlement_type.dart';

class PremiumService {
  final Subscription subscription;

  PremiumService(this.subscription);

  bool get isPremium => subscription.isPremium;

  bool hasEntitlement(EntitlementType entitlement) {
    // If user is premium, they get all entitlements for now.
    // This allows for future granular control if some entitlements are tier-specific.
    if (isPremium) return true;
    
    // Check if the specific entitlement is in the list
    return subscription.entitlements.contains(entitlement.name);
  }
}
