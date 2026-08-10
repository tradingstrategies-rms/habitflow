import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reward_redemption.dart';
import '../providers/reward_store_providers.dart';
import '../../../family/presentation/providers/family_provider.dart';

class FulfillmentTile extends ConsumerWidget {
  final RewardRedemption redemption;
  final VoidCallback? onFulfill;

  const FulfillmentTile({
    super.key,
    required this.redemption,
    this.onFulfill,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemAsync = ref.watch(rewardItemByIdProvider(redemption.rewardItemId));
    final familyState = ref.watch(familyProvider);
    final childProfile = familyState.profiles.cast<dynamic>().firstWhere(
      (p) => p.id == redemption.profileId,
      orElse: () => null,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
        title: itemAsync.when(
          data: (item) => Text(item?.title ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
          loading: () => const Text('...'),
          error: (_, __) => const Text('Error'),
        ),
        subtitle: Text('Approved for ${childProfile?.displayName ?? 'Child'}'),
        trailing: ElevatedButton(
          onPressed: onFulfill,
          child: const Text('Mark Fulfilled'),
        ),
      ),
    );
  }
}
