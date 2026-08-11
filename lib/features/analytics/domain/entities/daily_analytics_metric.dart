import 'package:flutter/foundation.dart';

@immutable
class DailyAnalyticsMetric {
  final DateTime date;
  final bool isActive;
  final int completionCount;

  const DailyAnalyticsMetric({
    required this.date,
    required this.isActive,
    required this.completionCount,
  });
}
