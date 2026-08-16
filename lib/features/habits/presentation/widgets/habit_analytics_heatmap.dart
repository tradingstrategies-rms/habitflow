import 'package:flutter/material.dart';
import '../../domain/entities/habit_completion.dart';

class HabitAnalyticsHeatmap extends StatelessWidget {
  final List<HabitCompletion> completions;
  final Color baseColor;

  const HabitAnalyticsHeatmap({
    super.key,
    required this.completions,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text('Activity Heatmap', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 35, // 5 weeks
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: 34 - index));
                final isCompleted = completions.any((c) => 
                  c.completionDate.year == date.year && 
                  c.completionDate.month == date.month && 
                  c.completionDate.day == date.day
                );

                return Container(
                  decoration: BoxDecoration(
                    color: isCompleted ? baseColor : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
