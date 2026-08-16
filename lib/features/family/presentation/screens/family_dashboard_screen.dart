import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/invitation_inbox.dart';
import 'package:habitflow/features/family/presentation/widgets/family_productivity_score_card.dart';

import 'package:habitflow/features/family/domain/entities/family_achievement.dart';
import 'package:habitflow/features/family/presentation/providers/family_achievement_provider.dart';

class FamilyDashboardScreen extends ConsumerWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyCircle = ref.watch(familyProvider.select((s) => s.circle));
    final profiles = ref.watch(familyProvider.select((s) => s.profiles));
    final isLoading = ref.watch(familyProvider.select((s) => s.isLoading));

    // Achievement Celebration Listener
    ref.listen(newAchievementEventProvider, (prev, next) {
      if (next != null) {
        _showAchievementCelebration(context, next);
        ref.read(newAchievementEventProvider.notifier).state = null;
      }
    });

    final session = ref.watch(activeProfileSessionProvider);
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (familyCircle == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(HFSpacing.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.family_restroom, size: 64, color: Colors.grey),
                const SizedBox(height: HFSpacing.m),
                Text(
                  'Your Family Journey',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: HFSpacing.s),
                const Text(
                  'Create a shared space for growing together.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HFSpacing.l),
                ElevatedButton(
                  onPressed: () => context.pushNamed(RouteNames.familyCreate),
                  child: const Text('Create Family Circle'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Safely determine the active profile
    FamilyProfile? activeProfile;
    try {
      activeProfile = profiles.firstWhere(
        (p) => p.id == session?.profileId,
        orElse: () => profiles.firstWhere(
          (p) => p.role == FamilyRole.owner,
          orElse: () => profiles.first,
        ),
      );
    } catch (_) {
      if (profiles.isNotEmpty) {
        activeProfile = profiles.first;
      }
    }

    if (activeProfile == null) {
      return const Scaffold(body: Center(child: Text('Initializing...')));
    }


    final isChild = activeProfile.profileType == ProfileType.child;
    final pendingApprovalsAsync = ref.watch(allPendingApprovalsProvider);
    final pendingCount = pendingApprovalsAsync.maybeWhen(
      data: (approvals) => approvals.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isChild ? 'My Habits' : 'Family Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.pushNamed(RouteNames.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.familySettings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyProvider.notifier).loadFamily(),
        child: ListView(
          padding: const EdgeInsets.all(HFSpacing.m),
          children: [
            const FamilyInvitationInbox(),
            FamilyProductivityScoreCard(isChild: isChild),
            const SizedBox(height: HFSpacing.m),
            _buildSharedHabitsCard(context, ref),
            const SizedBox(height: HFSpacing.m),
            _buildAchievementsCard(context, ref),
            const SizedBox(height: HFSpacing.m),
            _buildCurrentProfileCard(context, activeProfile),
            const SizedBox(height: HFSpacing.l),
            Text(
              'Manage Family',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: HFSpacing.s),
            ..._buildNavigationCards(context, activeProfile, pendingCount),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedHabitsCard(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(sharedHabitsSummaryProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      data: (summary) {
        if (summary.total == 0) return const SizedBox.shrink();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: InkWell(
            onTap: () => context.pushNamed(RouteNames.familySharedHabits),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist_rtl, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Shared Habits',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${summary.completed}/${summary.total}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(context, 'Assigned', summary.total.toString(), Icons.people_outline),
                      _buildStatItem(context, 'Completed', summary.completed.toString(), Icons.check_circle_outline),
                      _buildStatItem(context, 'Pending', summary.pending.toString(), Icons.hourglass_empty, color: theme.colorScheme.secondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.onSurfaceVariant.withAlpha(150)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAchievementsCard(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(familyAchievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final theme = Theme.of(context);

    if (achievements.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(RouteNames.familyAchievements),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unlocked.length} of ${achievements.length} unlocked',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (unlocked.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(unlocked.last.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Recent: ${unlocked.last.name}',
                              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer.withAlpha(50), shape: BoxShape.circle),
                child: Icon(Icons.emoji_events_outlined, color: theme.colorScheme.tertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementCelebration(BuildContext context, FamilyAchievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(achievement.icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text('Achievement Unlocked!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            Text(achievement.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(achievement.description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Great!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentProfileCard(BuildContext context, FamilyProfile profile) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile.role.displayName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.familyProfileSelector),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Switch'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavigationCards(BuildContext context, FamilyProfile profile, int pendingCount) {
    final isChild = profile.profileType == ProfileType.child;

    final List<_NavCardData> items = [
      if (!isChild)
        _NavCardData(
          title: 'Members',
          subtitle: 'Manage your family circle',
          icon: Icons.people_outline,
          onTap: () => context.pushNamed(RouteNames.familyMembers),
        ),
      if (!isChild)
        _NavCardData(
          title: 'Pending Approvals',
          subtitle: 'Review child habit completions',
          icon: Icons.pending_actions,
          onTap: () => context.pushNamed(RouteNames.familyApprovals, extra: profile.id),
          badgeCount: pendingCount,
        ),
      _NavCardData(
        title: 'Shared Habits',
        subtitle: 'Habits for the whole family',
        icon: Icons.checklist_rtl,
        onTap: () => context.pushNamed(RouteNames.familySharedHabits),
      ),
      _NavCardData(
        title: 'Activity Feed',
        subtitle: 'See what everyone is up to',
        icon: Icons.history,
        onTap: () => context.pushNamed(RouteNames.familyActivity),
      ),
      _NavCardData(
        title: 'Family Achievements',
        subtitle: 'Unlocked milestones and badges',
        icon: Icons.emoji_events_outlined,
        onTap: () => context.pushNamed(RouteNames.familyAchievements),
      ),
      if (!isChild)
        _NavCardData(
          title: 'Family Settings',
          subtitle: 'Security, privacy and preferences',
          icon: Icons.settings_outlined,
          onTap: () => context.pushNamed(RouteNames.familySettings),
        ),
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: HFSpacing.s),
              child: _buildNavigationCard(context, item),
            ))
        .toList();
  }

  Widget _buildNavigationCard(BuildContext context, _NavCardData item) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: theme.colorScheme.primary),
        ),
        title: Row(
          children: [
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (item.badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.badgeCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          item.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: item.onTap,
      ),
    );
  }
}

class _NavCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  _NavCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });
}
