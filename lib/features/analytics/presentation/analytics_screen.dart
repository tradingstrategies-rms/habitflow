import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'widgets/habit_heatmap.dart';
import 'widgets/analytics_summary_cards.dart';
import 'widgets/analytics_trend_section.dart';
import 'widgets/habit_intelligence_section.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final selectedHabitId = ref.watch(selectedAnalyticsHabitIdProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: const HFTopAppBar(title: 'Analytics'),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: HFEmptyState(
                title: 'No Active Habits',
                message: 'Start tracking habits to see your analytics here.',
                icon: Icons.bar_chart_rounded,
              ),
            );
          }

          // Default to first habit if none selected
          final habitId = selectedHabitId ?? habits.first.id;
          
          final now = DateTime.now();
          final end = DateTime(now.year, now.month, now.day);
          final start = end.subtract(period);

          final metrics = ref.watch(habitAnalyticsProvider((habitId, start, end)));
          final dailyMetrics = ref.watch(habitDailyAnalyticsProvider((habitId, start, end)));
          final trend = ref.watch(habitAnalyticsTrendProvider((habitId, period)));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(HFSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitSelector(ref, habits, habitId),
                const SizedBox(height: HFSpacing.l),
                _buildPeriodSelector(ref, period),
                const SizedBox(height: HFSpacing.l),
                AnalyticsSummaryCards(metrics: metrics),
                const SizedBox(height: HFSpacing.l),
                AnalyticsTrendSection(trend: trend),
                const SizedBox(height: HFSpacing.xl),
                HabitIntelligenceSection(habitId: habitId, period: period),
                const SizedBox(height: HFSpacing.xl),
                HabitHeatmap(metrics: dailyMetrics),
                const SizedBox(height: HFSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const Center(child: HFLoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHabitSelector(WidgetRef ref, List<Habit> habits, String selectedId) {
    final theme = Theme.of(ref.context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Habit',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: HFSpacing.s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: habits.map((habit) => Padding(
              padding: const EdgeInsets.only(right: HFSpacing.s),
              child: ChoiceChip(
                label: Text(habit.title),
                selected: selectedId == habit.id,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedAnalyticsHabitIdProvider.notifier).state = habit.id;
                  }
                },
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, Duration selectedPeriod) {
    final periods = {
      '7 Days': const Duration(days: 7),
      '30 Days': const Duration(days: 30),
      '90 Days': const Duration(days: 90),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(right: HFSpacing.s),
          child: HFChip(
            label: entry.key,
            isSelected: selectedPeriod == entry.value,
            onTap: () => ref.read(analyticsPeriodProvider.notifier).state = entry.value,
          ),
        )).toList(),
      ),
    );
  }
}
