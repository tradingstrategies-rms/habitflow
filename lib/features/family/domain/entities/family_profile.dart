import 'package:flutter/foundation.dart';
import '../enums/profile_type.dart';
import '../enums/family_role.dart';

@immutable
class FamilyProfile {
  final String id;
  final String familyId;
  final String displayName;
  final ProfileType profileType;
  final FamilyRole role;
  final String? userId;
  final String? avatarUrl;
  final bool requiresPin;
  final DateTime createdAt;

  const FamilyProfile({
    required this.id,
    required this.familyId,
    required this.displayName,
    required this.profileType,
    required this.role,
    this.userId,
    this.avatarUrl,
    required this.requiresPin,
    required this.createdAt,
  });

  FamilyProfile copyWith({
    String? id,
    String? familyId,
    String? displayName,
    ProfileType? profileType,
    FamilyRole? role,
    String? userId,
    String? avatarUrl,
    bool? requiresPin,
    DateTime? createdAt,
  }) {
    return FamilyProfile(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      displayName: displayName ?? this.displayName,
      profileType: profileType ?? this.profileType,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requiresPin: requiresPin ?? this.requiresPin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          familyId == other.familyId &&
          displayName == other.displayName &&
          profileType == other.profileType &&
          role == other.role &&
          userId == other.userId &&
          avatarUrl == other.avatarUrl &&
          requiresPin == other.requiresPin &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      familyId.hashCode ^
      displayName.hashCode ^
      profileType.hashCode ^
      role.hashCode ^
      userId.hashCode ^
      avatarUrl.hashCode ^
      requiresPin.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'FamilyProfile(id: $id, familyId: $familyId, displayName: $displayName, profileType: $profileType, role: $role, userId: $userId, avatarUrl: $avatarUrl, requiresPin: $requiresPin, createdAt: $createdAt)';
}
