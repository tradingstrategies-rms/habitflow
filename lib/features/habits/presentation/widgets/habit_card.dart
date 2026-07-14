import 'package:flutter/material.dart';
import '../../domain/models/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit, this.onTap, this.onDismissed});
  final Habit habit;
  final VoidCallback? onTap;
  final Function(DismissDirection)? onDismissed;

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
        ),
      ),
    );
  }
}
