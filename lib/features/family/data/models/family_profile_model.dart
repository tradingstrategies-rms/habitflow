import '../../domain/entities/family_profile.dart';
import '../../domain/enums/family_role.dart';
import '../../domain/enums/profile_type.dart';

class FamilyProfileModel extends FamilyProfile {
  const FamilyProfileModel({
    required super.id,
    required super.familyId,
    required super.displayName,
    required super.profileType,
    required super.role,
    super.userId,
    super.avatarUrl,
    required super.requiresPin,
    required super.createdAt,
  });

  factory FamilyProfileModel.fromEntity(FamilyProfile entity) {
    return FamilyProfileModel(
      id: entity.id,
      familyId: entity.familyId,
      displayName: entity.displayName,
      profileType: entity.profileType,
      role: entity.role,
      userId: entity.userId,
      avatarUrl: entity.avatarUrl,
      requiresPin: entity.requiresPin,
      createdAt: entity.createdAt,
    );
  }

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyProfileModel(
      id: json['id']?.toString() ?? '',
      familyId: json['familyId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      profileType: json['profileType'] != null
          ? ProfileType.values.firstWhere(
              (e) => e.name == json['profileType'].toString(),
              orElse: () => ProfileType.adult,
            )
          : ProfileType.adult,
      role: json['role'] != null
          ? FamilyRole.values.firstWhere(
              (e) => e.name == json['role'].toString(),
              orElse: () => FamilyRole.adultMember,
            )
          : FamilyRole.adultMember,
      userId: json['userId']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      requiresPin: json['requiresPin'] == true,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'displayName': displayName,
      'profileType': profileType.name,
      'role': role.name,
      'userId': userId,
      'avatarUrl': avatarUrl,
      'requiresPin': requiresPin,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FamilyProfile toEntity() {
    return FamilyProfile(
      id: id,
      familyId: familyId,
      displayName: displayName,
      profileType: profileType,
      role: role,
      userId: userId,
      avatarUrl: avatarUrl,
      requiresPin: requiresPin,
      createdAt: createdAt,
    );
  }
}
