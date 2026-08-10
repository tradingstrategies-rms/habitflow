import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reward_store_providers.dart';
import '../widgets/redemption_history_tile.dart';

class RedemptionHistoryScreen extends ConsumerWidget {
  final String profileId;

  const RedemptionHistoryScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(redemptionHistoryProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redemption History'),
      ),
      body: historyAsync.when(
        data: (redemptions) {
          if (redemptions.isEmpty) {
            return const Center(child: Text('No redemption history found.'));
          }

          return ListView.separated(
            itemCount: redemptions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final redemption = redemptions[index];
              final itemAsync = ref.watch(rewardItemByIdProvider(redemption.rewardItemId));
              
              return itemAsync.when(
                data: (item) => RedemptionHistoryTile(
                  redemption: redemption,
                  item: item,
                ),
                loading: () => const ListTile(title: Text('Loading...')),
                error: (_, __) => RedemptionHistoryTile(redemption: redemption),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
