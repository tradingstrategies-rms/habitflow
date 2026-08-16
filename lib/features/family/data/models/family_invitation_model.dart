import '../../domain/entities/family_invitation.dart';
import '../../domain/enums/invitation_status.dart';

class FamilyInvitationModel extends FamilyInvitation {
  const FamilyInvitationModel({
    required super.id,
    required super.familyId,
    required super.familyName,
    required super.invitedEmail,
    required super.invitedBy,
    required super.invitedByName,
    required super.invitedAt,
    required super.status,
    required super.inviterProfileId,
    required super.token,
    required super.createdAt,
    required super.expiresAt,
    super.usedAt,
    super.usedByProfileId,
  });

  factory FamilyInvitationModel.fromEntity(FamilyInvitation entity) {
    return FamilyInvitationModel(
      id: entity.id,
      familyId: entity.familyId,
      familyName: entity.familyName,
      invitedEmail: entity.invitedEmail,
      invitedBy: entity.invitedBy,
      invitedByName: entity.invitedByName,
      invitedAt: entity.invitedAt,
      status: entity.status,
      inviterProfileId: entity.inviterProfileId,
      token: entity.token,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      usedAt: entity.usedAt,
      usedByProfileId: entity.usedByProfileId,
    );
  }

  factory FamilyInvitationModel.fromJson(Map<String, dynamic> json) {
    return FamilyInvitationModel(
      id: json['id']?.toString() ?? '',
      familyId: json['familyId']?.toString() ?? '',
      familyName: json['familyName']?.toString() ?? '',
      invitedEmail: json['invitedEmail']?.toString() ?? '',
      invitedBy: json['invitedBy']?.toString() ?? '',
      invitedByName: json['invitedByName']?.toString() ?? '',
      invitedAt: json['invitedAt'] != null
          ? DateTime.parse(json['invitedAt'].toString())
          : DateTime.now(),
      status: json['status'] != null
          ? InvitationStatus.values.firstWhere(
              (e) => e.name == json['status'].toString(),
              orElse: () => InvitationStatus.pending,
            )
          : InvitationStatus.pending,
      inviterProfileId: json['inviterProfileId']?.toString() ?? json['invitedBy']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['invitedAt'] != null ? DateTime.parse(json['invitedAt'].toString()) : DateTime.now()),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : DateTime.now().add(const Duration(days: 7)),
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt'].toString()) : null,
      usedByProfileId: json['usedByProfileId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'familyName': familyName,
      'invitedEmail': invitedEmail,
      'invitedBy': invitedBy,
      'invitedByName': invitedByName,
      'invitedAt': invitedAt.toIso8601String(),
      'status': status.name,
      'inviterProfileId': inviterProfileId,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'usedByProfileId': usedByProfileId,
    };
  }
}
