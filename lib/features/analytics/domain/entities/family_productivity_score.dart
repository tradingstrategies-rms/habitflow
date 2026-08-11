import 'package:flutter/foundation.dart';
import 'analytics_trend.dart';

@immutable
class FamilyProductivityScore {
  final String familyId;
  final double score;
  final DateTime startDate;
  final DateTime endDate;
  final int participatingProfileCount;
  final double averageActivityRate;
  final AnalyticsTrendDirection trend;
  final double trendDelta;

  const FamilyProductivityScore({
    required this.familyId,
    required this.score,
    required this.startDate,
    required this.endDate,
    required this.participatingProfileCount,
    required this.averageActivityRate,
    required this.trend,
    required this.trendDelta,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyProductivityScore &&
          runtimeType == other.runtimeType &&
          familyId == other.familyId &&
          score == other.score &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          participatingProfileCount == other.participatingProfileCount &&
          averageActivityRate == other.averageActivityRate &&
          trend == other.trend &&
          trendDelta == other.trendDelta);

  @override
  int get hashCode =>
      familyId.hashCode ^
      score.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      participatingProfileCount.hashCode ^
      averageActivityRate.hashCode ^
      trend.hashCode ^
      trendDelta.hashCode;
}
