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
          ? (DateTime.tryParse(json['invitedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      status: json['status'] != null
          ? InvitationStatus.values.firstWhere(
              (e) => e.name == json['status'].toString(),
              orElse: () => InvitationStatus.pending,
            )
          : InvitationStatus.pending,
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
    };
  }
}
