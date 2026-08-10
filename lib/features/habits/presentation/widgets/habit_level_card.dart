import 'package:flutter/material.dart';

class HabitLevelCard extends StatelessWidget {
  const HabitLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('LEVEL 12', style: TextStyle(fontSize: 12)),
            const Text('Organic Oak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            LinearProgressIndicator(value: 0.7, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
