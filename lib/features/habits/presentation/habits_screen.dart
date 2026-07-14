import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import '../data/habit_providers.dart';
import 'widgets/habit_card.dart';
import 'screens/habit_edit_screen.dart';
import 'package:habitflow/features/habits/domain/models/habit.dart';
import 'package:habitflow/features/habits/application/habit_controller.dart';

final sortFilterProvider = StateProvider<String>((ref) => 'recent');

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);
    
    return Scaffold(
      appBar: HFTopAppBar(
        title: 'Habits',
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => ref.read(sortFilterProvider.notifier).state = val,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'recent', child: Text('Recently Updated')),
              PopupMenuItem(value: 'name', child: Text('Name A-Z')),
            ],
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          final sorted = List.of(habits);
          final filter = ref.watch(sortFilterProvider);
          if (filter == 'name') sorted.sort((a, b) => a.title.compareTo(b.title));
          
          return sorted.isEmpty
            ? HFEmptyState(
                title: 'No Habits',
                message: 'Start tracking your daily progress.',
                icon: Icons.check_circle_outline,
                actionLabel: 'Add Habit',
                onActionPressed: () => _navigateToEdit(context),
              )
            : ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final habit = sorted[index];
                  return HabitCard(
                    habit: habit,
                    onTap: () => _navigateToEdit(context, habit: habit),
                    onDismissed: (_) => ref.read(habitControllerProvider.notifier).deleteHabit(habit.id),
                  );
                },
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, {Habit? habit}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HabitEditScreen(habit: habit),
    ));
  }
}
