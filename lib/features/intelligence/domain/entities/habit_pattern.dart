enum PatternType {
  morningStrength,
  eveningStrength,
  weekdayStrength,
  weekendWeakness,
  improvingTrend,
  decliningTrend,
  highConsistency,
  lowConsistency,
  longInactiveGap,
  fastRecovery,
  slowRecovery,
  frequentMisses,
  bestDayOfWeek,
  weakestDayOfWeek,
  custom,
}

enum PatternSeverity {
  low,
  medium,
  high,
}

enum PatternConfidence {
  low,
  medium,
  high,
}

class HabitPattern {
  final String id;
  final String habitId;
  final PatternType type;
  final PatternSeverity severity;
  final PatternConfidence confidence;
  final String titleKey;
  final Map<String, dynamic> metrics;
  final DateTime detectedAt;

  const HabitPattern({
    required this.id,
    required this.habitId,
    required this.type,
    required this.severity,
    required this.confidence,
    required this.titleKey,
    required this.metrics,
    required this.detectedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitPattern &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          type == other.type &&
          severity == other.severity &&
          confidence == other.confidence &&
          titleKey == other.titleKey &&
          detectedAt == other.detectedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      type.hashCode ^
      severity.hashCode ^
      confidence.hashCode ^
      titleKey.hashCode ^
      detectedAt.hashCode;
}
