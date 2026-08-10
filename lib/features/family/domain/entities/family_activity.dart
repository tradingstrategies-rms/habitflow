import 'package:flutter/foundation.dart';
import '../enums/family_activity_type.dart';

@immutable
class FamilyActivity {
  final String id;
  final String familyId;
  final String? profileId;
  final String? profileName;
  final String? profileAvatarUrl;
  final FamilyActivityType type;
  final String description;
  final String? metadata; // e.g. habitId, habitName, achievementId
  final DateTime timestamp;

  const FamilyActivity({
    required this.id,
    required this.familyId,
    this.profileId,
    this.profileName,
    this.profileAvatarUrl,
    required this.type,
    required this.description,
    this.metadata,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          familyId == other.familyId &&
          type == other.type &&
          timestamp == other.timestamp);

  @override
  int get hashCode =>
      id.hashCode ^ familyId.hashCode ^ type.hashCode ^ timestamp.hashCode;
}
