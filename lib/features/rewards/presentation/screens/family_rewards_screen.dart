import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';

class FamilyRewardsScreen extends ConsumerWidget {
  const FamilyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Rewards'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildTeamHeader(theme),
          const SizedBox(height: 32),
          _buildCollectiveCard(theme),
          const SizedBox(height: 40),
          Text(
            "Today's Contribution",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...familyState.profiles.map((profile) {
            final accountAsync = ref.watch(rewardAccountProvider(profile.id));
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: MemberAvatar(profileType: profile.profileType, avatarUrl: profile.avatarUrl, radius: 20),
                title: Text(profile.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('LVL ${accountAsync.value?.level ?? 1}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.circle, size: 8, color: i < 2 ? Colors.green : theme.colorScheme.outlineVariant),
                    )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(ThemeData theme) {
    return Column(
      children: [
        const Center(
          child: Text('Everyone completed\nhabits today!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        ),
        const SizedBox(height: 12),
        Text(
          'Incredible teamwork! Your family\'s shared garden is flourishing.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildCollectiveCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Family Tree', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Lvl 12', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Collective Growth Level', style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.park_rounded, size: 64, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            const Text('GROWING STEADILY', style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
