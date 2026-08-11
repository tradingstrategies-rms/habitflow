import 'package:flutter/material.dart';
import 'package:habitflow/features/analytics/domain/entities/daily_analytics_metric.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:intl/intl.dart';

class HabitHeatmap extends StatelessWidget {
  final List<DailyAnalyticsMetric> metrics;

  const HabitHeatmap({
    super.key,
    required this.metrics,
  });

  Color _getColor(BuildContext context, int count) {
    if (count == 0) {
      return Theme.of(context).colorScheme.outline.withAlpha(HFOpacity.alpha20);
    }
    final primary = Theme.of(context).colorScheme.primary;
    if (count == 1) return primary.withAlpha(76); // 0.3 * 255
    if (count == 2) return primary.withAlpha(127); // 0.5 * 255
    if (count == 3) return primary.withAlpha(191); // 0.75 * 255
    return primary;
  }

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: HFSpacing.s),
          child: Text(
            'Activity Map',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDaysOfWeek(context),
              const SizedBox(width: HFSpacing.xs),
              _buildGrid(context),
            ],
          ),
        ),
        const SizedBox(height: HFSpacing.m),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildDaysOfWeek(BuildContext context) {
    final days = ['Mon', 'Wed', 'Fri', 'Sun'];
    return Column(
      children: [
        const SizedBox(height: 20), // Header offset
        ...days.map((day) => Container(
              height: 32, // (box size 24 + spacing 8) * 2 - but we skip some days
              alignment: Alignment.centerLeft,
              child: Text(
                day,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                    ),
              ),
            )),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    // Group metrics into weeks
    final List<List<DailyAnalyticsMetric?>> weeks = [];
    List<DailyAnalyticsMetric?> currentWeek = List.filled(7, null);

    for (var metric in metrics) {
      final weekday = metric.date.weekday - 1; // 0 = Mon, 6 = Sun
      if (weekday == 0 && currentWeek.any((m) => m != null)) {
        weeks.add(currentWeek);
        currentWeek = List.filled(7, null);
      }
      currentWeek[weekday] = metric;
    }
    if (currentWeek.any((m) => m != null)) {
      weeks.add(currentWeek);
    }

    return Row(
      children: weeks.map((week) => _buildWeekColumn(context, week)).toList(),
    );
  }

  Widget _buildWeekColumn(BuildContext context, List<DailyAnalyticsMetric?> week) {
    // Show month label if it's the first week of the month or first week in list
    String? monthLabel;
    final firstNonNull = week.firstWhere((m) => m != null, orElse: () => null);
    if (firstNonNull != null) {
      if (firstNonNull.date.day <= 7) {
        monthLabel = DateFormat('MMM').format(firstNonNull.date);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: monthLabel != null
              ? Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                      ),
                )
              : null,
        ),
        ...week.map((metric) => _buildDayBox(context, metric)),
      ],
    );
  }

  Widget _buildDayBox(BuildContext context, DailyAnalyticsMetric? metric) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: metric == null ? Colors.transparent : _getColor(context, metric.completionCount),
        borderRadius: BorderRadius.circular(4),
      ),
      child: metric != null
          ? Tooltip(
              message: '${DateFormat('MMM d').format(metric.date)}: ${metric.completionCount} completions',
              child: const SizedBox.expand(),
            )
          : null,
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
              ),
        ),
        const SizedBox(width: HFSpacing.xs),
        _buildLegendBox(context, 0),
        _buildLegendBox(context, 1),
        _buildLegendBox(context, 2),
        _buildLegendBox(context, 3),
        _buildLegendBox(context, 4),
        const SizedBox(width: HFSpacing.xs),
        Text(
          'More',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
              ),
        ),
      ],
    );
  }

  Widget _buildLegendBox(BuildContext context, int level) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _getColor(context, level),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
