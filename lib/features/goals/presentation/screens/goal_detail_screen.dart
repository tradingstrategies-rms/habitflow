import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_progress_indicator.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_analytics_card.dart';
import 'package:habitflow/features/goals/presentation/widgets/goal_insight_card.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String? goalId;

  const GoalDetailScreen({
    super.key,
    this.goalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We prefer selectedGoalProvider but can fall back to goalByIdProvider if deep linking
    final goal = ref.watch(selectedGoalProvider) ?? 
                 (goalId != null ? ref.watch(goalByIdProvider(goalId!)) : null);

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final progressAsync = ref.watch(goalProgressProvider(goal));

    return Scaffold(
      appBar: HFTopAppBar(
        title: 'HabitFlow',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HFSpacing.ml),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentitySection(context, goal, progressAsync),
            const SizedBox(height: HFSpacing.l),
            GoalAnalyticsCard(goalId: goal.id),
            const SizedBox(height: HFSpacing.m),
            GoalInsightCard(goalId: goal.id),
            const SizedBox(height: HFSpacing.l),
            _buildBentoGrid(context, goal, progressAsync),
            const SizedBox(height: HFSpacing.l),
            _buildLinkedHabitsSection(context, goal),
            const SizedBox(height: HFSpacing.l),
            _buildMilestonesPlaceholder(context),
            const SizedBox(height: HFSpacing.xl),
            _buildActions(context, goal, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, Goal goal, AsyncValue progressAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(HFRadius.button),
              ),
              child: Icon(
                _getIconData(goal.iconName),
                size: 32,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                semanticLabel: 'Goal category icon',
              ),
            ),
            const SizedBox(width: HFSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      HFChip(label: goal.scope.name.toUpperCase()),
                      const SizedBox(width: HFSpacing.s),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: HFSpacing.s),
                      progressAsync.when(
                        data: (p) => Text(
                          '${p.percentage.toInt()}% Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: HFSpacing.m),
        progressAsync.when(
          data: (p) => GoalProgressIndicator(
            progress: p,
            strokeWidth: 12,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, Goal goal, AsyncValue progressAsync) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: HFSpacing.m,
      crossAxisSpacing: HFSpacing.m,
      childAspectRatio: 1.5,
      children: [
        HFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIMEFRAME',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                  ),
                  Icon(Icons.calendar_month, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.scope.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ends ${DateFormat.yMMMd().format(goal.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        HFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GROWTH',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                  ),
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              progressAsync.when(
                data: (p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.completedValue.toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total achieved',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedHabitsSection(BuildContext context, Goal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Linked Habits',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: HFSpacing.m),
        if (goal.habitIds.isEmpty)
          const Text('No linked habits')
        else
          ...goal.habitIds.map((id) => _HabitListItem(habitId: id)),
      ],
    );
  }

  Widget _buildMilestonesPlaceholder(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: HFSpacing.m),
        HFCard(
          child: Column(
            children: [
              _buildMilestoneItem(context, 'Define vision', 'Achieved', true),
              const Divider(),
              _buildMilestoneItem(context, 'First milestone', 'In progress', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(BuildContext context, String title, String status, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: completed ? TextDecoration.lineThrough : null,
                        color: completed ? Theme.of(context).colorScheme.outline : null,
                      ),
                ),
                Text(status, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Goal goal, WidgetRef ref) {
    final isArchived = goal.status == GoalStatus.archived;

    return Row(
      children: [
        Expanded(
          child: HFButton(
            label: isArchived ? 'Restore Goal' : 'Archive Goal',
            variant: HFButtonVariant.secondary,
            icon: isArchived ? Icons.unarchive : Icons.archive,
            onPressed: () {
              if (isArchived) {
                ref.read(goalControllerProvider.notifier).restoreGoal(goal.id);
              } else {
                ref.read(goalControllerProvider.notifier).archiveGoal(goal.id);
              }
            },
          ),
        ),
        const SizedBox(width: HFSpacing.m),
        Expanded(
          child: HFButton(
            label: 'Edit Goal',
            variant: HFButtonVariant.primary,
            icon: Icons.edit,
            onPressed: () => context.pushNamed(RouteNames.editGoal, extra: goal),
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'piano': return Icons.piano_rounded;
      case 'flight_takeoff': return Icons.flight_takeoff_rounded;
      case 'directions_run': return Icons.directions_run_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'extension': return Icons.extension_rounded;
      case 'rocket_launch': return Icons.rocket_launch_rounded;
      case 'park': return Icons.park_rounded;
      default: return Icons.emoji_events_rounded;
    }
  }
}

class _HabitListItem extends ConsumerWidget {
  final String habitId;

  const _HabitListItem({required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return habitAsync.when(
      data: (habit) {
        if (habit == null) return const SizedBox();
        return HFCard(
          margin: const EdgeInsets.only(bottom: HFSpacing.s),
          padding: const EdgeInsets.all(HFSpacing.sm),
          elevation: 0,
          border: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: HFSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(habit.unit, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading habit'),
    );
  }
}
