import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/application/providers/reminder_providers.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_action_section.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_analytics_heatmap.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_completion_timeline.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_statistics_card.dart';
import 'package:habitflow/features/habits/presentation/widgets/habit_weekly_insights.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final Habit? habit;
  final String? habitId;
  const HabitDetailsScreen({super.key, this.habit, this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = habit != null 
        ? AsyncValue.data(habit!) 
        : ref.watch(habitByIdProvider(habitId ?? ''));

    return habitAsync.when(
      data: (habit) {
        if (habit == null) return const Scaffold(body: Center(child: Text('Habit not found')));
        final completionsAsync = ref.watch(habitCompletionsProvider(habit.id));

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: HFTopAppBar(
            title: 'Analytics',
            leading: HFIconButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header Section
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'habit_${habit.id}',
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_mapIconToData(habit.icon), size: 64, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(habit.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (habit.description != null && habit.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(habit.description!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Premium Stats Row
                Row(
                  children: [
                    Expanded(
                      child: ref.watch(streakProvider(habit.id)).when(
                        data: (streak) => HabitStatisticsCard(label: 'Current Streak', value: '$streak Days', icon: Icons.local_fire_department),
                        loading: () => const HabitStatisticsCard(label: 'Current Streak', value: '...', icon: Icons.local_fire_department),
                        error: (_, __) => const HabitStatisticsCard(label: 'Current Streak', value: '0 Days', icon: Icons.local_fire_department),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ref.watch(bestStreakProvider(habit.id)).when(
                        data: (streak) => HabitStatisticsCard(label: 'Best Streak', value: '$streak Days', icon: Icons.workspace_premium),
                        loading: () => const HabitStatisticsCard(label: 'Best Streak', value: '...', icon: Icons.workspace_premium),
                        error: (_, __) => const HabitStatisticsCard(label: 'Best Streak', value: '0 Days', icon: Icons.workspace_premium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ref.watch(completionPercentageProvider(habit.id)).when(
                  data: (percent) => HabitStatisticsCard(
                    label: 'Completion Rate (30d)', 
                    value: '${percent.toInt()}%', 
                    icon: Icons.donut_large
                  ),
                  loading: () => const HabitStatisticsCard(label: 'Completion Rate', value: '...', icon: Icons.donut_large),
                  error: (_, __) => const HabitStatisticsCard(label: 'Completion Rate', value: '0%', icon: Icons.donut_large),
                ),
                
                const SizedBox(height: 32),
                
                // Analytics Visuals
                completionsAsync.when(
                  data: (completions) => Column(
                    children: [
                      HabitWeeklyInsights(completions: completions, baseColor: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      HabitAnalyticsHeatmap(completions: completions, baseColor: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 32),
                      HabitCompletionTimeline(completions: completions),
                    ],
                  ),
                  loading: () => const Center(child: HFLoadingIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),
                
                // Reminder Configuration Entry Point
                ref.watch(habitReminderProvider(habit.id)).when(
                  data: (reminder) => Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      onTap: () => context.pushNamed(RouteNames.reminderSettings, extra: habit.id),
                      leading: Icon(
                        reminder?.enabled == true ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                        color: reminder?.enabled == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                      ),
                      title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        reminder?.enabled == true 
                          ? 'Scheduled for ${reminder!.timeOfDay.format(context)}'
                          : 'Notifications disabled',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 48),
                HabitActionSection(
                  isArchived: habit.isArchived,
                  onEdit: () => context.pushNamed(RouteNames.createHabit, extra: habit),
                  onArchive: () async {
                    final controller = ref.read(habitControllerProvider);
                    if (habit.isArchived) {
                      await controller.restoreHabit(habit.id);
                    } else {
                      await controller.archiveHabit(habit.id);
                    }
                    if (context.mounted) context.pop();
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Habit?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(habitControllerProvider).deleteHabit(habit.id);
                      if (context.mounted) context.pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: HFLoadingIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  IconData _mapIconToData(HabitIcon icon) {
    switch (icon) {
      case HabitIcon.water: return Icons.water_drop;
      case HabitIcon.book: return Icons.menu_book;
      case HabitIcon.running: return Icons.directions_run;
      case HabitIcon.meditation: return Icons.self_improvement;
      case HabitIcon.finance: return Icons.attach_money;
      case HabitIcon.family: return Icons.family_restroom;
      case HabitIcon.sleep: return Icons.bed;
      case HabitIcon.food: return Icons.restaurant;
      case HabitIcon.exercise: return Icons.fitness_center;
      case HabitIcon.custom: return Icons.edit_note;
    }
  }
}
