import 'package:flutter/foundation.dart';

@immutable
class AnalyticsMetrics {
  final String habitId;
  final String? profileId;
  final DateTime startDate;
  final DateTime endDate;
  final int completedCount;
  final int activeDays;
  final double activityRate;
  final int longestStreak;
  final double averageGapDays;

  const AnalyticsMetrics({
    required this.habitId,
    this.profileId,
    required this.startDate,
    required this.endDate,
    required this.completedCount,
    required this.activeDays,
    required this.activityRate,
    required this.longestStreak,
    required this.averageGapDays,
  });
}
