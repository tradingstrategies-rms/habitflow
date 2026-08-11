import 'package:flutter/material.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

class AnalyticsTrendSection extends StatelessWidget {
  final AnalyticsTrend trend;

  const AnalyticsTrendSection({
    super.key,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTrendColor(theme);
    final icon = _getTrendIcon();
    final label = _getTrendLabel();

    return HFCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(HFSpacing.s),
            decoration: BoxDecoration(
              color: color.withAlpha(HFOpacity.alpha10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: HFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Trend',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(trend.delta * 100).toStringAsFixed(1).replaceFirst('-', '')}%',
                style: theme.textTheme.displaySmall,
              ),
              Text(
                'vs prev. period',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(ThemeData theme) {
    switch (trend.direction) {
      case AnalyticsTrendDirection.improving:
        return theme.colorScheme.primary;
      case AnalyticsTrendDirection.declining:
        return theme.colorScheme.error;
      case AnalyticsTrendDirection.stable:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getTrendIcon() {
    switch (trend.direction) {
      case AnalyticsTrendDirection.improving:
        return Icons.trending_up_rounded;
      case AnalyticsTrendDirection.declining:
        return Icons.trending_down_rounded;
      case AnalyticsTrendDirection.stable:
        return Icons.trending_flat_rounded;
    }
  }

  String _getTrendLabel() {
    switch (trend.direction) {
      case AnalyticsTrendDirection.improving:
        return 'Improving';
      case AnalyticsTrendDirection.declining:
        return 'Declining';
      case AnalyticsTrendDirection.stable:
        return 'Stable';
    }
  }
}
