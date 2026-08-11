import 'package:flutter/foundation.dart';
import 'analytics_metrics.dart';

enum AnalyticsTrendDirection {
  improving,
  declining,
  stable,
}

@immutable
class AnalyticsTrend {
  final AnalyticsTrendDirection direction;
  final AnalyticsMetrics recent;
  final AnalyticsMetrics baseline;
  final double delta;

  const AnalyticsTrend({
    required this.direction,
    required this.recent,
    required this.baseline,
    required this.delta,
  });

  double get recentRate => recent.activityRate;
  double get baselineRate => baseline.activityRate;
}
