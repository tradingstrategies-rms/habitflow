import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

/// [HFRewardCard] displays an item in the Reward Vault.
/// 
/// ### Example Usage:
/// ```dart
/// HFRewardCard(
///   title: 'Extra Gaming Time',
///   cost: 150,
///   isLocked: false,
/// )
/// ```
class HFRewardCard extends StatelessWidget {
  /// Creates an [HFRewardCard].
  const HFRewardCard({
    super.key,
    required this.title,
    required this.cost,
    required this.isLocked,
    this.icon,
    this.onTap,
  });

  /// The name of the reward.
  final String title;

  /// The point cost to claim the reward.
  final int cost;

  /// Whether the reward is currently locked for the user.
  final bool isLocked;

  /// Optional icon for the reward.
  final IconData? icon;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HFCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: HFSpacing.m),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(HFSpacing.m),
            decoration: BoxDecoration(
              color: isLocked 
                ? theme.colorScheme.outline.withAlpha(HFOpacity.alpha20) 
                : theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.card_giftcard_rounded,
              color: isLocked 
                ? theme.colorScheme.outline 
                : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60) : null,
                  ),
                ),
                Text(
                  '$cost points',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(Icons.lock_rounded, color: theme.colorScheme.outline, size: 20),
        ],
      ),
    );
  }
}
