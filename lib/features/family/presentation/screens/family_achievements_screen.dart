import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/family_achievement.dart';
import 'package:habitflow/features/family/presentation/providers/family_achievement_provider.dart';

class FamilyAchievementsScreen extends ConsumerWidget {
  const FamilyAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(familyAchievementsProvider);

    // Group by category
    final categories = <String, List<FamilyAchievement>>{};
    for (final a in achievements) {
      categories.putIfAbsent(a.category, () => []).add(a);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Family Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(HFSpacing.m),
        children: [
          _buildSummary(context, achievements),
          const SizedBox(height: 24),
          ...categories.entries.map((entry) => _buildCategory(context, entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<FamilyAchievement> achievements) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$unlocked of $total achievements unlocked', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : unlocked / total,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String name, List<FamilyAchievement> achievements) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text(name.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) => _AchievementCard(achievement: achievements[index]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final FamilyAchievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = !achievement.isUnlocked;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(isLocked ? 50 : 100)),
      ),
      color: isLocked ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: TextStyle(fontSize: 40, color: isLocked ? theme.colorScheme.outline.withAlpha(100) : null),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked ? theme.colorScheme.outline : null,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            if (isLocked) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ] else 
              Text(
                'Unlocked!',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
