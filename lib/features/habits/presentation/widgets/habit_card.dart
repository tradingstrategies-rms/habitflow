import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/family/domain/enums/shared_habit_completion_mode.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'habit_streak_badge.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeProfile = ref.watch(activeProfileProvider);
    
    final canManage = activeProfile?.role == FamilyRole.owner || 
                      activeProfile?.role == FamilyRole.parent;

    return Dismissible(
      key: Key(habit.id),
      direction: canManage ? DismissDirection.horizontal : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Habit?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(habitControllerProvider).deleteHabit(habit.id);
            return true;
          }
          return false;
        } else {
          await ref.read(habitControllerProvider).archiveHabit(habit.id);
          return true;
        }
      },
      onDismissed: (_) {
        // Logic handled in confirmDismiss to avoid sync issues with Riverpod streams
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => context.pushNamed(
            RouteNames.habitDetails,
            pathParameters: {'habitId': habit.id},
            extra: habit,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(_mapIconToData(habit.icon), color: theme.colorScheme.onPrimaryContainer, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                            child: Text(habit.category.name.toUpperCase(), style: theme.textTheme.labelSmall),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ref.watch(streakProvider(habit.id)).when(
                              data: (streak) => HabitStreakBadge(streak: streak),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ref.watch(completionPercentageProvider(habit.id)).when(
                              data: (percent) => Text(
                                '${percent.toInt()}%',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final activeProfile = ref.watch(activeProfileProvider);
                    final isChild = activeProfile?.profileType == ProfileType.child;
                    
                    final sharedHabitAsync = ref.watch(sharedHabitByHabitIdProvider(habit.id));
                    final SharedHabit? sharedHabit = sharedHabitAsync.value;

                    final completionAsync = ref.watch(todayCompletionProvider(habit.id));
                    final anyCompletionAsync = ref.watch(anyTodayCompletionProvider(habit.id));
                    
                    bool isCompleted = false;
                    bool showPending = false;

                    if (sharedHabit != null) {
                      if (sharedHabit.completionMode == SharedHabitCompletionMode.anyOne) {
                        isCompleted = anyCompletionAsync.value != null;
                      } else {
                        isCompleted = completionAsync.value != null;
                      }
                    } else {
                      isCompleted = completionAsync.value != null;
                    }

                    final pendingApproval = ref.watch(habitPendingApprovalProvider(habit.id));
                    showPending = isChild && pendingApproval != null;

                    return Column(
                      children: [
                        InkWell(
                          onTap: (isCompleted || showPending)
                              ? null
                              : () async {
                                  if (isChild) {
                                    await ref.read(approvalNotifierProvider.notifier).requestApproval(
                                          childId: activeProfile!.id,
                                          childName: activeProfile.displayName,
                                          habitId: habit.id,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Awaiting Parent Approval')),
                                      );
                                    }
                                  } else {
                                    await ref.read(habitControllerProvider).toggleCompletion(
                                      habit.id, 
                                      isCompleted,
                                      profileId: activeProfile?.id,
                                    );
                                    ref.invalidate(todayCompletionProvider(habit.id));
                                    ref.invalidate(anyTodayCompletionProvider(habit.id));
                                  }
                                },
                          customBorder: const CircleBorder(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : (showPending
                                      ? Icons.pending_actions
                                      : Icons.circle_outlined),
                              key: ValueKey(isCompleted ? 1 : (showPending ? 2 : 3)),
                              size: 32,
                              color: isCompleted
                                  ? theme.colorScheme.primary
                                  : (showPending
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.outline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showPending ? 'PENDING' : (isCompleted ? 'DONE' : 'SWIPE'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: showPending
                                ? theme.colorScheme.secondary
                                : (isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline),
                          ),
                        ),
                        if (sharedHabit != null)
                          Text('SHARED', style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange, fontSize: 8)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _mapIconToData(HabitIcon icon) {
    switch (icon) {
      case HabitIcon.water: return Icons.water_drop;
      case HabitIcon.book: return Icons.menu_book;
      case HabitIcon.running: return Icons.directions_run;
      case HabitIcon.meditation: return Icons.self_improvement;
      case HabitIcon.finance: return Icons.attach_money;
      case HabitIcon.family: return Icons.family_restroom;
      case HabitIcon.sleep: return Icons.bed;
      case HabitIcon.food: return Icons.restaurant;
      case HabitIcon.exercise: return Icons.fitness_center;
      case HabitIcon.custom: return Icons.edit_note;
    }
  }
}
