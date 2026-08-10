import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/child_habit_card.dart';
import 'package:habitflow/features/family/presentation/widgets/pending_approval_banner.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';

class ChildDashboardScreen extends ConsumerWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final familyState = ref.watch(familyProvider);
    final session = ref.watch(activeProfileSessionProvider);

    final activeProfile = familyState.profiles.firstWhere(
      (p) => p.id == session?.profileId,
      orElse: () => familyState.profiles.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      body: ListView(
        padding: const EdgeInsets.all(HFSpacing.m),
        children: [
          _buildCurrentProfileCard(context, activeProfile),
          const SizedBox(height: HFSpacing.l),
          const PendingApprovalBanner(),
          const SizedBox(height: HFSpacing.m),
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) return const Center(child: Text('No habits assigned.'));
              return Column(
                children: habits.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: HFSpacing.s),
                  child: ChildHabitCard(
                    habit: h,
                    onComplete: () async {
                      await ref.read(approvalNotifierProvider.notifier).requestApproval(
                        childId: activeProfile.id,
                        childName: activeProfile.displayName,
                        habitId: h.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Awaiting Parent Approval')),
                        );
                      }
                    },
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentProfileCard(BuildContext context, FamilyProfile profile) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HFSpacing.m),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
              child: profile.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: HFSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName, style: theme.textTheme.titleSmall),
                  Text(
                    'CHILD',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => context.pushNamed(RouteNames.familyProfileSelector),
              icon: const Icon(Icons.switch_account_outlined, size: 16),
              label: const Text('Switch'),
            ),
          ],
        ),
      ),
    );
  }
}
