import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class ArchivedHabitsScreen extends ConsumerWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedHabitsProvider);

    return Scaffold(
      appBar: const HFTopAppBar(
        title: 'Archived Habits',
        centerTitle: true,
      ),
      body: archivedAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: HFEmptyState(
                title: 'No Archived Habits',
                message: 'Habits you archive will appear here.',
                icon: Icons.archive_outlined,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _ArchivedHabitCard(habit: habit);
            },
          );
        },
        loading: () => const Center(child: HFLoadingIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ArchivedHabitCard extends ConsumerWidget {
  final Habit habit;
  const _ArchivedHabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Opacity(
              opacity: 0.6,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_mapIconToData(habit.icon), size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('ARCHIVED', style: theme.textTheme.labelSmall),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.unarchive_outlined),
              tooltip: 'Restore',
              onPressed: () async {
                await ref.read(habitControllerProvider).restoreHabit(habit.id);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Delete',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Habit?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(habitControllerProvider).deleteHabit(habit.id);
                }
              },
            ),
          ],
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
