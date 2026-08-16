import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class PremiumFeatureLockedView extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final EntitlementType? entitlement;

  const PremiumFeatureLockedView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline_rounded,
    this.entitlement,
  });

  @override
  ConsumerState<PremiumFeatureLockedView> createState() => _PremiumFeatureLockedViewState();
}

class _PremiumFeatureLockedViewState extends ConsumerState<PremiumFeatureLockedView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.recordPremiumEvent(PremiumTelemetryEvent(
        type: PremiumEventType.lockedFeatureViewed,
        timestamp: DateTime.now(),
        entitlement: widget.entitlement?.name,
        source: widget.title,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProfile = ref.watch(activeProfileProvider);
    final isChild = activeProfile?.profileType == ProfileType.child;

    final displayTitle = isChild ? 'Grown-up Feature' : widget.title;
    final displayMessage = isChild 
        ? 'Ask a parent to help you unlock this feature!' 
        : widget.message;
    final displayIcon = widget.entitlement?.icon ?? widget.icon;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(HFSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayIcon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: HFSpacing.xl),
            Text(
              displayTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HFSpacing.m),
            Text(
              displayMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.entitlement != null && !isChild) ...[
              const SizedBox(height: HFSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: HFSpacing.m),
                child: Text(
                  widget.entitlement!.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: HFSpacing.xxl),
            if (!isChild) ...[
              HFButton(
                label: 'View Premium Plans',
                onPressed: () {
                  ref.recordPremiumEvent(PremiumTelemetryEvent(
                    type: PremiumEventType.upgradeStarted,
                    timestamp: DateTime.now(),
                    source: 'locked_view_${widget.title}',
                  ));
                  context.pushNamed(RouteNames.subscription);
                },
              ),
              const SizedBox(height: HFSpacing.m),
            ],
            HFButton(
              label: isChild ? 'Back' : 'Maybe Later',
              variant: HFButtonVariant.text,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

extension on EntitlementType {
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
}
