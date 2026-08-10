import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';

import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

class ChildHabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback onComplete;

  const ChildHabitCard({super.key, required this.habit, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completionAsync = ref.watch(todayCompletionProvider(habit.id));
    final isCompleted = completionAsync.value != null;
    final pendingApproval = ref.watch(habitPendingApprovalProvider(habit.id));
    final sharedHabitAsync = ref.watch(sharedHabitByHabitIdProvider(habit.id));
    final isShared = sharedHabitAsync.value != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isShared ? Colors.orange.withAlpha(50) : theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isShared ? Colors.orange.withAlpha(40) : theme.colorScheme.primaryContainer.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : (pendingApproval != null ? Icons.pending_actions : Icons.circle_outlined),
            color: isCompleted ? theme.colorScheme.primary : (pendingApproval != null ? theme.colorScheme.secondary : (isShared ? Colors.orange : theme.colorScheme.primary)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                habit.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (isShared)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.withAlpha(40), borderRadius: BorderRadius.circular(6)),
                child: const Text('SHARED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
          ],
        ),
        subtitle: Text(
          isCompleted ? 'Completed Today!' : (pendingApproval != null ? 'Awaiting parent approval' : 'Tap to complete'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCompleted ? theme.colorScheme.primary : (pendingApproval != null ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant),
          ),
        ),
        trailing: isCompleted 
          ? const Icon(Icons.check_circle, color: Colors.green) 
          : (pendingApproval != null 
              ? Icon(Icons.hourglass_bottom_rounded, color: theme.colorScheme.secondary) 
              : IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: onComplete,
                )),
      ),
    );
  }
}
