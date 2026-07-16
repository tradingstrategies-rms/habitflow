import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/habits/data/habit_providers.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_completion_controller.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);
    final todaysCompletions = ref.watch(todaysCompletionsProvider);

    return Scaffold(
      body: habitsAsync.when(
        data: (habits) {
          final activeHabits = habits.where((h) => !h.isArchived).toList();
          final completedCount = activeHabits.where((h) => todaysCompletions.contains(h.id.value)).length;
          final progress = activeHabits.isEmpty ? 0.0 : (completedCount / activeHabits.length);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    const HFSectionHeader(title: 'Overview'),
                    Row(
                      children: [
                        Expanded(
                          child: HFStatCard(
                            label: 'Today\'s Progress',
                            value: '${(progress * 100).toInt()}%',
                            icon: Icons.track_changes,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: HFStatCard(
                            label: 'Active Habits',
                            value: '${activeHabits.length}',
                            icon: Icons.task_alt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const HFSectionHeader(title: 'Today\'s Habits'),
                    ...activeHabits.map((habit) {
                      final isCompleted = todaysCompletions.contains(habit.id.value);
                      return HFHabitTile(
                        title: habit.title,
                        isCompleted: isCompleted,
                        streakCount: 0, // Placeholder
                        onToggle: () => ref.read(completionControllerProvider.notifier).toggleCompletion(habit.id, isCompleted),
                        onTap: () => context.pushNamed(RouteNames.habits), // Simplified navigation
                        color: Color(habit.color.value),
                      );
                    }),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.habits),
        child: const Icon(Icons.add),
      ),
    );
  }
}
