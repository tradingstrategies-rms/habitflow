import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_calculation_provider.dart';

class RewardPreviewCard extends ConsumerWidget {
  const RewardPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeProfileSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final accountAsync = ref.watch(rewardAccountProvider(session.profileId));
    final calcService = ref.watch(rewardCalculationServiceProvider);
    final theme = Theme.of(context);

    return accountAsync.when(
      data: (account) {
        if (account == null) return const SizedBox.shrink();

        final levelProgress = calcService.calculateLevelProgress(account.experience);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: InkWell(
            onTap: () => context.goNamed(RouteNames.rewards),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${account.points} Stars',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level ${account.level} - Consistency Builder',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
