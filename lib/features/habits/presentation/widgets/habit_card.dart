import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/habit.dart';
import 'habit_completion_controller.dart';

class HabitCard extends ConsumerWidget {
  const HabitCard({super.key, required this.habit, this.onTap, this.onDismissed, this.isCompleted = false});
  final Habit habit;
  final VoidCallback? onTap;
  final Function(DismissDirection)? onDismissed;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(habit.id.value),
      onDismissed: onDismissed,
      background: Container(color: Colors.red),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(habit.color.value),
            child: Text(habit.icon.value),
          ),
          title: Text(habit.title),
          subtitle: Text(habit.category.name),
          trailing: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(completionControllerProvider.notifier).toggleCompletion(habit.id, isCompleted);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : null,
              ),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
