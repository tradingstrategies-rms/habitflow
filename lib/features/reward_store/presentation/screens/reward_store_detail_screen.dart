import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reward_item.dart';
import '../providers/reward_store_providers.dart';
import '../widgets/reward_cost_badge.dart';
import '../../../family/presentation/providers/active_profile_session_provider.dart';
import '../../../rewards/presentation/providers/reward_account_provider.dart';

class RewardStoreDetailScreen extends ConsumerWidget {
  final RewardItem item;

  const RewardStoreDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(activeProfileSessionProvider);
    final accountAsync = session != null 
        ? ref.watch(rewardAccountProvider(session.profileId))
        : const AsyncValue.data(null);

    final bool canAfford = accountAsync.maybeWhen(
      data: (acc) => acc != null && acc.points >= item.pointsCost,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Icon(
                      Icons.card_giftcard_rounded,
                      size: 100,
                      color: theme.colorScheme.primary.withAlpha(50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RewardCostBadge(cost: item.pointsCost, fontSize: 20, iconSize: 24),
                  const SizedBox(height: 24),
                  Text(
                    'About this Reward',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canAfford ? () => _handleRedeem(context, ref) : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        canAfford ? 'Redeem Reward' : 'Not Enough Stars',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRedeem(BuildContext context, WidgetRef ref) async {
    final session = ref.read(activeProfileSessionProvider);
    if (session == null) return;

    final controller = ref.read(rewardStoreControllerProvider);

    try {
      await controller.redeemItem(session.profileId, item.id);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your reward has been redeemed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
