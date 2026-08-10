import 'package:flutter/material.dart';
import '../../domain/entities/reward_item.dart';
import 'reward_cost_badge.dart';

class RewardStoreCard extends StatelessWidget {
  final RewardItem item;
  final VoidCallback? onTap;

  const RewardStoreCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnavailable = !item.isAvailable;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: InkWell(
        onTap: isUnavailable ? null : onTap,
        child: Opacity(
          opacity: isUnavailable ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: item.imageUrl != null 
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Icon(
                          _getIconForCategory(item.category),
                          size: 48,
                          color: theme.colorScheme.primary.withAlpha(100),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RewardCostBadge(cost: item.pointsCost),
                        if (isUnavailable)
                          Text(
                            'UNAVAILABLE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(dynamic category) {
    // Simplified mapping for foundation
    return Icons.card_giftcard_rounded;
  }
}
