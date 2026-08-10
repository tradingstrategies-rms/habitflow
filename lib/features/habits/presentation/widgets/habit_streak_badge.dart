import 'package:flutter/material.dart';

class HabitStreakBadge extends StatelessWidget {
  final int streak;
  const HabitStreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$streak Day Streak',
            style: const TextStyle(color: Colors.orange),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
