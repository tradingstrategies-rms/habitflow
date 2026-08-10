import 'package:flutter/foundation.dart';

@immutable
class FamilyMember {
  final String profileId;
  final int currentStreak;
  final double completionRate;
  final bool completedToday;

  const FamilyMember({
    required this.profileId,
    required this.currentStreak,
    required this.completionRate,
    required this.completedToday,
  });

  FamilyMember copyWith({
    String? profileId,
    int? currentStreak,
    double? completionRate,
    bool? completedToday,
  }) {
    return FamilyMember(
      profileId: profileId ?? this.profileId,
      currentStreak: currentStreak ?? this.currentStreak,
      completionRate: completionRate ?? this.completionRate,
      completedToday: completedToday ?? this.completedToday,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMember &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          currentStreak == other.currentStreak &&
          completionRate == other.completionRate &&
          completedToday == other.completedToday);

  @override
  int get hashCode =>
      profileId.hashCode ^
      currentStreak.hashCode ^
      completionRate.hashCode ^
      completedToday.hashCode;

  @override
  String toString() =>
      'FamilyMember(profileId: $profileId, currentStreak: $currentStreak, completionRate: $completionRate, completedToday: $completedToday)';
}
