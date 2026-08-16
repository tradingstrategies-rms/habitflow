import 'package:flutter/foundation.dart';
import '../enums/invitation_status.dart';

@immutable
class FamilyInvitation {
  final String id;
  final String familyId;
  final String familyName;
  final String invitedEmail;
  final String invitedBy;
  final String invitedByName;
  final DateTime invitedAt;
  final InvitationStatus status;
  
  // New fields for Sprint 9.3.1
  final String inviterProfileId;
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String? usedByProfileId;

  const FamilyInvitation({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.invitedEmail,
    required this.invitedBy,
    required this.invitedByName,
    required this.invitedAt,
    required this.status,
    required this.inviterProfileId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    this.usedAt,
    this.usedByProfileId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isRevoked => status == InvitationStatus.revoked;

  bool isValidForFamily(String targetFamilyId) {
    return familyId == targetFamilyId;
  }

  FamilyInvitation copyWith({
    String? id,
    String? familyId,
    String? familyName,
    String? invitedEmail,
    String? invitedBy,
    String? invitedByName,
    DateTime? invitedAt,
    InvitationStatus? status,
    String? inviterProfileId,
    String? token,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    String? usedByProfileId,
  }) {
    return FamilyInvitation(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      invitedAt: invitedAt ?? this.invitedAt,
      status: status ?? this.status,
      inviterProfileId: inviterProfileId ?? this.inviterProfileId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      usedByProfileId: usedByProfileId ?? this.usedByProfileId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyInvitation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          familyId == other.familyId &&
          token == other.token &&
          status == other.status);

  @override
  int get hashCode =>
      id.hashCode ^
      familyId.hashCode ^
      token.hashCode ^
      status.hashCode;
}
