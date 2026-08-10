import 'package:flutter/material.dart';
import '../../domain/entities/habit_completion.dart';

class HabitWeeklyInsights extends StatelessWidget {
  final List<HabitCompletion> completions;
  final Color baseColor;

  const HabitWeeklyInsights({
    super.key,
    required this.completions,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final date = DateTime.now().subtract(Duration(days: 6 - index));
                final isCompleted = completions.any((c) => 
                  c.completionDate.year == date.year && 
                  c.completionDate.month == date.month && 
                  c.completionDate.day == date.day
                );

                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? baseColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isCompleted ? null : Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                    const SizedBox(height: 8),
                    Text(days[date.weekday - 1], style: theme.textTheme.labelSmall),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
