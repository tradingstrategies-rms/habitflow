import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/presentation/screens/habits_empty_screen.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_card.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_category_filter.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_date_selector.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_level_card.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => context.pushNamed(RouteNames.archivedHabits),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.pushNamed(RouteNames.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) return const HabitsEmptyScreen();
          return Column(
            children: [
              const HabitDateSelector(),
              const HabitCategoryFilter(),
              Expanded(
                child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) => HabitCard(habit: habits[index]),
                ),
              ),
              const HabitLevelCard(),
            ],
          );
        },
        loading: () => const Center(child: HFLoadingIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.createHabit),
        child: const Icon(Icons.add),
      ),
    );
  }
}
