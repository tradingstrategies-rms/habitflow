import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import '../../domain/enums/reward_category.dart';
import '../providers/reward_store_providers.dart';
import '../widgets/reward_store_card.dart';
import '../widgets/reward_category_filter.dart';
import '../widgets/reward_balance_header.dart';
import '../../../family/presentation/providers/active_profile_session_provider.dart';

import '../../../family/domain/enums/family_role.dart';
import '../../../family/presentation/providers/active_profile_provider.dart';
import '../widgets/pending_redemption_tile.dart';

import '../widgets/fulfillment_tile.dart';

class RewardStoreScreen extends ConsumerStatefulWidget {
  const RewardStoreScreen({super.key});

  @override
  ConsumerState<RewardStoreScreen> createState() => _RewardStoreScreenState();
}

class _RewardStoreScreenState extends ConsumerState<RewardStoreScreen> {
  RewardCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(rewardCatalogProvider);
    final session = ref.watch(activeProfileSessionProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final isParent = activeProfile?.role == FamilyRole.owner || 
                     activeProfile?.role == FamilyRole.parent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Store'),
        actions: [
          if (session != null)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => context.pushNamed(
                RouteNames.redemptionHistory,
                pathParameters: {'profileId': session.profileId},
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: RewardBalanceHeader(),
                ),
                if (isParent) ...[
                  _buildPendingSection(context),
                  _buildFulfillmentSection(context),
                ],
                RewardCategoryFilter(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          catalogAsync.when(
            data: (items) {
              final filteredItems = _selectedCategory == null
                  ? items
                  : items.where((i) => i.category == _selectedCategory).toList();

              if (filteredItems.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No rewards available.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return RewardStoreCard(
                        item: item,
                        onTap: () => context.pushNamed(
                          RouteNames.rewardStoreDetail,
                          pathParameters: {'rewardId': item.id},
                          extra: item,
                        ),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection(BuildContext context) {
    final pending = ref.watch(pendingRedemptionsProvider);
    if (pending.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'PENDING APPROVALS',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...pending.map((r) => PendingRedemptionTile(
          redemption: r,
          onApprove: () => ref.read(rewardStoreControllerProvider).approveRedemption(r.id),
          onReject: () => ref.read(rewardStoreControllerProvider).rejectRedemption(r.id),
        )),
        const Divider(indent: 24, endIndent: 24, height: 32),
      ],
    );
  }

  Widget _buildFulfillmentSection(BuildContext context) {
    final approved = ref.watch(approvedRedemptionsProvider);
    if (approved.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'AWAITING FULFILLMENT',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...approved.map((r) => FulfillmentTile(
          redemption: r,
          onFulfill: () => ref.read(rewardStoreControllerProvider).fulfillRedemption(r.id),
        )),
        const Divider(indent: 24, endIndent: 24, height: 32),
      ],
    );
  }
}
