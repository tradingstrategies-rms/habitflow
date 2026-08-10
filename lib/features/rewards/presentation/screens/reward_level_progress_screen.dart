import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_calculation_provider.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_level_diamond.dart';

class RewardLevelProgressScreen extends ConsumerWidget {
  const RewardLevelProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeProfileSessionProvider);
    final theme = Theme.of(context);
    
    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final accountAsync = ref.watch(rewardAccountProvider(profileId));
    final calcService = ref.watch(rewardCalculationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: accountAsync.when(
        data: (account) {
          if (account == null) return const Center(child: Text('No account found'));
          final progress = calcService.calculateLevelProgress(account.experience);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(theme, account),
                const SizedBox(height: 48),
                _buildXpProgress(theme, account, progress),
                const SizedBox(height: 48),
                _buildUpcomingSection(theme),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic account) {
    return Column(
      children: [
        RewardLevelDiamond(level: account.level),
        const SizedBox(height: 32),
        Text(
          'Consistency Builder',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "You're proving that small daily actions lead to monumental growth.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildXpProgress(ThemeData theme, dynamic account, double progress) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    Text('CURRENT XP', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${account.experience}',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                        Text(' / 1000', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('NEXT LEVEL', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${1000 - account.experience} XP to go', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Daily Streak Active\nEarn 2x XP for your next habit completion.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildUpcomingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Upcoming: Level 9',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMilestoneCard(
          theme,
          level: '9',
          title: 'Habit Champion',
          description: 'Mastering the art of sustainable routines.',
          unlockText: 'Unlocks Premium Avatar Frames',
          icon: Icons.style_outlined,
        ),
        const SizedBox(height: 12),
        _buildMilestoneCard(
          theme,
          level: '10',
          title: 'Zen Master',
          description: 'Reaching the pinnacle of holistic wellness.',
          unlockText: 'Secret Reward',
          icon: Icons.auto_awesome_rounded,
          isSecret: true,
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(ThemeData theme, {required String level, required String title, required String description, required String unlockText, required IconData icon, bool isSecret = false}) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  level,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary.withAlpha(150)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(isSecret ? Icons.lock_outline : Icons.card_giftcard_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(unlockText, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
