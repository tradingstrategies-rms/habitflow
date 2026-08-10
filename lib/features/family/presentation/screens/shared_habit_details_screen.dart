import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/member_avatar.dart';

class SharedHabitDetailsScreen extends ConsumerWidget {
  final SharedHabit sharedHabit;

  const SharedHabitDetailsScreen({super.key, required this.sharedHabit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(sharedHabit.habitId));
    final theme = Theme.of(context);
    final familyProfiles = ref.watch(familyProvider).profiles;
    final approvalsAsync = ref.watch(allPendingApprovalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shared Habit Details')),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) return const Center(child: Text('Habit not found'));

          final pendingApprovals = approvalsAsync.value?.where((a) => a.habitId == habit.id).toList() ?? [];

          return ListView(
            padding: const EdgeInsets.all(HFSpacing.m),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withAlpha(30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
                        child: Icon(Icons.checklist_rtl, color: theme.colorScheme.primary, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(habit.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        sharedHabit.completionMode.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                      ),
                      const SizedBox(height: 8),
                      Text(sharedHabit.completionMode.description, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Assigned Members', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...sharedHabit.assignedMemberIds.map((memberId) {
                final profile = familyProfiles.firstWhere((p) => p.id == memberId, orElse: () => familyProfiles.first);
                final completionAsync = ref.watch(profileTodayCompletionProvider((habit.id, memberId)));
                final isDone = completionAsync.value != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: MemberAvatar(profileType: profile.profileType, avatarUrl: profile.avatarUrl, radius: 20),
                    title: Text(profile.displayName),
                    subtitle: Text(profile.role.displayName.toUpperCase(), style: theme.textTheme.labelSmall),
                    trailing: isDone 
                      ? const Icon(Icons.check_circle, color: Colors.green) 
                      : Icon(Icons.circle_outlined, color: theme.colorScheme.outline),
                  ),
                );
              }),
              if (pendingApprovals.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Pending Approvals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                const SizedBox(height: 12),
                ...pendingApprovals.map((approval) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: theme.colorScheme.secondaryContainer.withAlpha(30),
                  child: ListTile(
                    title: Text('Requested by ${approval.childName}'),
                    subtitle: Text(approval.createdAt.toString()), // Simple date for now
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => ref.read(approvalNotifierProvider.notifier).reject(approval),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => ref.read(approvalNotifierProvider.notifier).approve(approval),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
