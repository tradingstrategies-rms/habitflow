import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_transactions_provider.dart';

import 'package:habitflow/features/rewards/presentation/widgets/reward_level_diamond.dart';

class KidsRewardsDashboardScreen extends ConsumerWidget {
  const KidsRewardsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeProfileSessionProvider);
    
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final accountAsync = ref.watch(rewardAccountProvider(profileId));
    final transactionsAsync = ref.watch(rewardTransactionsProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.pushNamed(RouteNames.rewardHistory),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(rewardAccountProvider(profileId));
          ref.invalidate(rewardTransactionsProvider(profileId));
        },
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildBalanceCard(context, accountAsync.value),
            const SizedBox(height: 24),
            // _buildApprovalBanner(context), // Remove or fix if needed
            const SizedBox(height: 32),
            Text(
              "My Recent Wins",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) return const Center(child: Text('Complete habits to earn stars!'));
                return Column(
                  children: transactions.take(5).map((t) => _buildWinTile(context, t)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, dynamic account) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.lightBlue.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            RewardLevelDiamond(level: account?.level ?? 1, size: 80),
            const SizedBox(height: 24),
            Text(
              'My Growth Stars',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '${account?.points ?? 0}',
              style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.rewardStore),
              icon: const Icon(Icons.shopping_bag_rounded),
              label: const Text('Go to Toy Store', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinTile(BuildContext context, dynamic transaction) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50), shape: BoxShape.circle),
          child: Icon(_getIcon(transaction.source), color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Just now'),
        trailing: Icon(Icons.star_rounded, color: Colors.orange.withAlpha(150)),
      ),
    );
  }

  IconData _getIcon(dynamic source) {
    return Icons.school_outlined; // Simplified for kids
  }
}
