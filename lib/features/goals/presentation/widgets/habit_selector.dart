import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import '../../../../core/theme/hf_spacing.dart';

class HabitSelector extends ConsumerWidget {
  final List<String> selectedHabitIds;
  final ValueChanged<List<String>> onHabitsChanged;

  const HabitSelector({
    super.key,
    required this.selectedHabitIds,
    required this.onHabitsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LINKED HABITS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: HFSpacing.s),
        habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return const Text('No active habits found. Please create a habit first.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isSelected = selectedHabitIds.contains(habit.id);
                return CheckboxListTile(
                  title: Text(habit.title),
                  subtitle: Text(habit.category.name),
                  value: isSelected,
                  onChanged: (checked) {
                    final newList = List<String>.from(selectedHabitIds);
                    if (checked == true) {
                      newList.add(habit.id);
                    } else {
                      newList.remove(habit.id);
                    }
                    onHabitsChanged(newList);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error loading habits: $err'),
        ),
      ],
    );
  }
}
