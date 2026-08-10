import 'package:flutter/material.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:intl/intl.dart';

class RewardDetailScreen extends StatelessWidget {
  final RewardTransaction transaction;

  const RewardDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = transaction.amount >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildLargeIcon(theme),
            const SizedBox(height: 32),
            Text(
              transaction.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Habit Streak Reward', // Hardcoded for now based on design
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${isPositive ? '+' : ''}${transaction.amount} ${transaction.type == RewardType.xp ? 'XP' : 'Points'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildDetailRow(context, 'SOURCE', transaction.source.name),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'DATE', DateFormat('MMMM d, yyyy').format(transaction.createdAt)),
            const SizedBox(height: 64),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Share functionality
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share Milestone'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeIcon(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary.withAlpha(80), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.track_changes_rounded, size: 64, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
