import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_transactions_provider.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_empty_state.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_transaction_tile.dart';
import 'package:intl/intl.dart';

class RewardHistoryScreen extends ConsumerWidget {
  const RewardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeProfileSessionProvider);
    final theme = Theme.of(context);
    
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final transactionsAsync = ref.watch(rewardTransactionsProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              // TODO: Implement filter logic
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(rewardTransactionsProvider(profileId)),
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const RewardEmptyState(
                title: 'No History Found',
                message: 'Start completing habits to build your reward history!',
              );
            }

            final grouped = _groupTransactionsByDate(transactions);

            return ListView.builder(
              padding: const EdgeInsets.all(HFSpacing.m),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final date = grouped.keys.elementAt(index);
                final items = grouped[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Text(
                        _formatHeaderDate(date),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...items.map((t) => RewardTransactionTile(
                      transaction: t,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.rewardDetail,
                          pathParameters: {'transactionId': t.id},
                          extra: t,
                        );
                      },
                    )),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Map<DateTime, List<RewardTransaction>> _groupTransactionsByDate(List<RewardTransaction> transactions) {
    final Map<DateTime, List<RewardTransaction>> grouped = {};
    for (var t in transactions) {
      final date = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(t);
    }
    return grouped;
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'TODAY';
    if (date == yesterday) return 'YESTERDAY';
    return DateFormat('MMMM d, yyyy').format(date).toUpperCase();
  }
}
