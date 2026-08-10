import 'package:flutter/material.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:intl/intl.dart';

class RewardBalanceCard extends StatelessWidget {
  final RewardAccount account;
  final VoidCallback? onRedeemPressed;
  final VoidCallback? onHistoryPressed;
  final String nextLevelName;
  final double levelProgress;

  const RewardBalanceCard({
    super.key,
    required this.account,
    this.onRedeemPressed,
    this.onHistoryPressed,
    this.nextLevelName = 'Master',
    required this.levelProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat('#,###');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT BALANCE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          formatter.format(account.points),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onRedeemPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Level: $nextLevelName',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${account.experience} / 1000 XP', // Hardcoded 1000 for now as per design
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onHistoryPressed,
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text('History'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
