import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/billing/application/providers/billing_providers.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:intl/intl.dart';

extension EntitlementTypeX on EntitlementType {
  String get title {
    switch (this) {
      case EntitlementType.advancedAnalytics:
        return 'Advanced Analytics';
      case EntitlementType.premiumRewards:
        return 'Premium Rewards';
      case EntitlementType.premiumChallenges:
        return 'Premium Challenges';
      case EntitlementType.unlimitedFamilies:
        return 'Unlimited Families';
      case EntitlementType.unlimitedHabits:
        return 'Unlimited Habits';
    }
  }

  String get description {
    switch (this) {
      case EntitlementType.advancedAnalytics:
        return 'Deep dive into your habit patterns with 90-day history and trends.';
      case EntitlementType.premiumRewards:
        return 'Unlock special rewards and family leaderboards.';
      case EntitlementType.premiumChallenges:
        return 'Access elite challenges and view your complete challenge history.';
      case EntitlementType.unlimitedFamilies:
        return 'Create and manage as many family circles as you need.';
      case EntitlementType.unlimitedHabits:
        return 'Track an unlimited number of habits without restrictions.';
    }
  }

  IconData get icon {
    switch (this) {
      case EntitlementType.advancedAnalytics:
        return Icons.insights_rounded;
      case EntitlementType.premiumRewards:
        return Icons.star_rounded;
      case EntitlementType.premiumChallenges:
        return Icons.emoji_events_rounded;
      case EntitlementType.unlimitedFamilies:
        return Icons.family_restroom_rounded;
      case EntitlementType.unlimitedHabits:
        return Icons.all_inclusive_rounded;
    }
  }
}

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.recordPremiumEvent(PremiumTelemetryEvent(
        type: PremiumEventType.subscriptionScreenViewed,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStreamProvider).value;
    final premiumService = ref.watch(premiumServiceProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final isChild = activeProfile?.profileType == ProfileType.child;
    final theme = Theme.of(context);

    final productsAsync = ref.watch(availableProductsProvider);
    final purchaseState = ref.watch(purchaseStateProvider);
    final isLoading = purchaseState.isLoading;

    ref.listen(purchaseStateProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result == null) return;
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully upgraded to Premium!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (result.isCancelled) {
            // No snackbar for cancellation usually, just reset state
          } else if (result.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${result.errorMessage ?? "Unknown error"}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (result.isAlreadyOwned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You already have an active Premium subscription.')),
            );
          } else if (result.isNothingToRestore) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No previous purchases found to restore.')),
            );
          }
          ref.read(purchaseStateProvider.notifier).reset();
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $error'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
          ref.read(purchaseStateProvider.notifier).reset();
        },
      );
    });

    if (subscription == null) {
      return const Scaffold(body: Center(child: HFLoadingIndicator()));
    }

    return Scaffold(
      appBar: const HFTopAppBar(title: 'Subscription'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(HFSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context, subscription, premiumService.isPremium),
                  const SizedBox(height: HFSpacing.l),
                  Text(
                    'Premium Features',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: HFSpacing.s),
                  Text(
                    'Upgrade your experience and reach your goals faster.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: HFSpacing.l),
                  ...EntitlementType.values.map((e) => _buildEntitlementTile(context, e, premiumService.hasEntitlement(e))),
                  const SizedBox(height: HFSpacing.xl),
                  if (!premiumService.isPremium && !isChild) ...[
                    productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) return const Text('No products available.');
                        final product = products.first;
                        return Column(
                          children: [
                            HFButton(
                              label: 'Upgrade for ${product.formattedPrice}',
                              onPressed: isLoading ? null : () => ref.read(purchaseStateProvider.notifier).purchase(product.id),
                            ),
                            const SizedBox(height: HFSpacing.m),
                            HFButton(
                              label: 'Restore Purchases',
                              variant: HFButtonVariant.text,
                              onPressed: isLoading ? null : () => ref.read(purchaseStateProvider.notifier).restorePurchases(),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: HFLoadingIndicator()),
                      error: (err, stack) => const Text('Could not load products.'),
                    ),
                  ],
                  if (isChild)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: HFSpacing.l),
                        child: Text(
                          'Ask a parent to manage subscription settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  const SizedBox(height: HFSpacing.xxl),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withAlpha(50),
                child: const Center(child: HFLoadingIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, dynamic subscription, bool isPremium) {
    final theme = Theme.of(context);
    final status = subscription.status as SubscriptionStatus;
    
    Color statusColor;
    String statusText;
    
    switch (status) {
      case SubscriptionStatus.premium:
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case SubscriptionStatus.expired:
        statusColor = theme.colorScheme.error;
        statusText = 'Expired';
        break;
      case SubscriptionStatus.cancelled:
        statusColor = Colors.orange;
        statusText = 'Active (Cancelled)';
        break;
      case SubscriptionStatus.free:
        statusColor = theme.colorScheme.outline;
        statusText = 'Free';
        break;
    }

    return HFCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Plan'),
                  Text(
                    isPremium ? 'HabitFlow Premium' : 'HabitFlow Free',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          if (subscription.expiresAt != null) ...[
            const SizedBox(height: HFSpacing.m),
            const Divider(),
            const SizedBox(height: HFSpacing.m),
            Row(
              children: [
                const Icon(Icons.event_repeat_rounded, size: 16),
                const SizedBox(width: HFSpacing.s),
                Text(
                  'Renews on: ${DateFormat.yMMMMd().format(subscription.expiresAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          if (isPremium) ...[
            const SizedBox(height: HFSpacing.m),
            const Divider(),
            const SizedBox(height: HFSpacing.m),
            Row(
              children: [
                const Icon(Icons.payment_rounded, size: 16),
                const SizedBox(width: HFSpacing.s),
                const Expanded(child: Text('Manage in App Store / Google Play')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntitlementTile(BuildContext context, EntitlementType entitlement, bool hasAccess) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: HFSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasAccess 
                  ? theme.colorScheme.primaryContainer 
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entitlement.icon,
              color: hasAccess 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onSurfaceVariant.withAlpha(150),
              size: 24,
            ),
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entitlement.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entitlement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (hasAccess)
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
          else
            const Icon(Icons.lock_rounded, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
