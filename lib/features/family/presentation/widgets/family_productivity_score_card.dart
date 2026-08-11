import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/analytics/domain/entities/family_productivity_score.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';

class FamilyProductivityScoreCard extends ConsumerWidget {
  final bool isChild;

  const FamilyProductivityScoreCard({
    super.key,
    this.isChild = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 30-day productivity by default
    final scoreAsync = ref.watch(familyProductivityScoreProvider(const Duration(days: 30)));

    return scoreAsync.when(
      data: (score) => _buildScoreContent(context, score),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      error: (err, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error loading score: $err'),
        ),
      ),
    );
  }

  Widget _buildScoreContent(BuildContext context, FamilyProductivityScore score) {
    final theme = Theme.of(context);
    final trendColor = _getTrendColor(theme, score.trend);
    final trendIcon = _getTrendIcon(score.trend);
    final trendLabel = _getTrendLabel(score.trend);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withAlpha(HFOpacity.alpha20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary.withAlpha(HFOpacity.alpha20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChild ? 'Our Family Progress' : 'Family Productivity',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isChild 
                      ? 'Keep it up, team!' 
                      : '${score.participatingProfileCount} Members active (30d)',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isChild) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${score.trendDelta.abs().toStringAsFixed(1)} pts vs prev.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(HFOpacity.alpha80),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: score.score / 100,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  score.score.toInt().toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(ThemeData theme, AnalyticsTrendDirection trend) {
    switch (trend) {
      case AnalyticsTrendDirection.improving:
        return theme.colorScheme.primary;
      case AnalyticsTrendDirection.declining:
        return theme.colorScheme.error;
      case AnalyticsTrendDirection.stable:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getTrendIcon(AnalyticsTrendDirection trend) {
    switch (trend) {
      case AnalyticsTrendDirection.improving:
        return Icons.trending_up;
      case AnalyticsTrendDirection.declining:
        return Icons.trending_down;
      case AnalyticsTrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  String _getTrendLabel(AnalyticsTrendDirection trend) {
    switch (trend) {
      case AnalyticsTrendDirection.improving:
        return 'Improving';
      case AnalyticsTrendDirection.declining:
        return 'Declining';
      case AnalyticsTrendDirection.stable:
        return 'Stable';
    }
  }
}
