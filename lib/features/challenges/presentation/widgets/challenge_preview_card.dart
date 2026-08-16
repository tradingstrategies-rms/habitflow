import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_badge.dart';
import '../../domain/entities/challenge_progress.dart';
import '../providers/challenge_providers.dart';
import 'challenge_progress_card.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';

class ChallengePreviewCard extends ConsumerWidget {
  const ChallengePreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremiumChallenges = ref.watch(premiumServiceProvider).hasEntitlement(
      EntitlementType.premiumChallenges,
    );
    final theme = Theme.of(context);

    if (!hasPremiumChallenges) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        ),
        child: InkWell(
          onTap: () => context.pushNamed(RouteNames.challengesDashboard),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Challenges',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const PremiumBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Take on premium challenges designed to keep your momentum strong.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore Premium',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final session = ref.watch(activeProfileSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final activeChallengesAsync = ref.watch(activeChallengesProvider(session.profileId));
    final profileProgressAsync = ref.watch(profileProgressProvider(session.profileId));

    return activeChallengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) return const SizedBox.shrink();

        final nearestChallenge = challenges.first;
        final progressRecords = profileProgressAsync.value ?? [];
        final progress = progressRecords.firstWhere(
          (p) => p.challengeId == nearestChallenge.id,
          orElse: () => ChallengeProgress(
            challengeId: nearestChallenge.id,
            profileId: session.profileId,
            lastUpdatedAt: DateTime.now(),
            periodStartDate: DateTime.now(),
          ),
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: InkWell(
            onTap: () => context.pushNamed(RouteNames.challengesDashboard),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Active Challenges',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${challenges.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nearestChallenge.title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ChallengeProgressCard(
                    currentValue: progress.currentValue,
                    targetValue: nearestChallenge.targetValue,
                    unit: nearestChallenge.unit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View All Challenges',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
