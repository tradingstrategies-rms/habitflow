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

  const FamilyInvitation({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.invitedEmail,
    required this.invitedBy,
    required this.invitedByName,
    required this.invitedAt,
    required this.status,
  });

  FamilyInvitation copyWith({
    String? id,
    String? familyId,
    String? familyName,
    String? invitedEmail,
    String? invitedBy,
    String? invitedByName,
    DateTime? invitedAt,
    InvitationStatus? status,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyInvitation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          familyId == other.familyId &&
          invitedEmail == other.invitedEmail &&
          status == other.status);

  @override
  int get hashCode =>
      id.hashCode ^
      familyId.hashCode ^
      invitedEmail.hashCode ^
      status.hashCode;
}
