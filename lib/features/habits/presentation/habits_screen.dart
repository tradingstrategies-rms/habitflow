import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import '../data/habit_providers.dart';
import 'widgets/habit_card.dart';
import 'screens/habit_edit_screen.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);
    
    return Scaffold(
      appBar: const HFTopAppBar(title: 'Habits'),
      body: habitsAsync.when(
        data: (habits) => habits.isEmpty
            ? HFEmptyState(
                title: 'No Habits',
                message: 'Start tracking your daily progress.',
                icon: Icons.check_circle_outline,
                actionLabel: 'Add Habit',
                onActionPressed: () => _navigateToEdit(context),
              )
            : ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) => HabitCard(
                  habit: habits[index],
                  onTap: () => _navigateToEdit(context, habit: habits[index]),
                ),
              ),
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
