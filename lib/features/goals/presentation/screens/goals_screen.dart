import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_card.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_empty_state.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_error_state.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_loading_state.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalControllerProvider);

    if (goalState.isLoading && goalState.goals.isEmpty) {
      return const GoalLoadingState();
    }

    if (goalState.errorMessage != null && goalState.goals.isEmpty) {
      return GoalErrorState(
        message: goalState.errorMessage!,
        onRetry: () => ref.read(goalControllerProvider.notifier).loadGoals(),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goals'),
          actions: [
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GoalList(
              goals: goalState.activeGoals,
              onRefresh: () => ref.read(goalControllerProvider.notifier).loadGoals(),
            ),
            _GoalList(
              goals: goalState.completedGoals,
              onRefresh: () => ref.read(goalControllerProvider.notifier).loadGoals(),
            ),
            _GoalList(
              goals: goalState.archivedGoals,
              onRefresh: () => ref.read(goalControllerProvider.notifier).loadGoals(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed(RouteNames.createGoal),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

class _GoalList extends ConsumerWidget {
  final List<Goal> goals;
  final Future<void> Function() onRefresh;

  const _GoalList({
    required this.goals,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (goals.isEmpty) {
      return const GoalEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(HFSpacing.m),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GoalCard(
            goal: goal,
            onTap: () {
              ref.read(goalControllerProvider.notifier).selectGoal(goal);
              context.pushNamed(
                RouteNames.goalDetails,
                pathParameters: {'goalId': goal.id},
              );
            },
          );
        },
      ),
    );
  }
}
