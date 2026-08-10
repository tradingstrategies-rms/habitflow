import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitsEmptyScreen extends ConsumerWidget {
  const HabitsEmptyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the illustration - Using an icon for now as per project style
            Icon(
              Icons.energy_savings_leaf_outlined,
              size: 200,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 32),
            Text(
              'Build Better Habits',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first habit and begin building a healthier, happier lifestyle.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            HFButton(
              label: 'Create Habit',
              onPressed: () => context.pushNamed(RouteNames.createHabit),
            ),
            const SizedBox(height: 16),
            HFButton(
              label: 'Browse Templates',
              variant: HFButtonVariant.secondary,
              onPressed: () {
                // TODO: Navigate to templates
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.createHabit),
        label: const Text('Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
