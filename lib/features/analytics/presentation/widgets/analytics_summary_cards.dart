import 'package:flutter/material.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  final AnalyticsMetrics metrics;

  const AnalyticsSummaryCards({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: HFSpacing.m,
      crossAxisSpacing: HFSpacing.m,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          context,
          'Activity Rate',
          '${(metrics.activityRate * 100).toStringAsFixed(1)}%',
          Icons.speed_rounded,
        ),
        _buildMetricCard(
          context,
          'Active Days',
          '${metrics.activeDays}',
          Icons.calendar_today_rounded,
        ),
        _buildMetricCard(
          context,
          'Longest Streak',
          '${metrics.longestStreak} days',
          Icons.local_fire_department_rounded,
        ),
        _buildMetricCard(
          context,
          'Avg. Gap',
          '${metrics.averageGapDays.toStringAsFixed(1)} days',
          Icons.space_bar_rounded,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return HFCard(
      padding: const EdgeInsets.all(HFSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: HFSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }
}
