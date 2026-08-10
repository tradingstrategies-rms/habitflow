import '../../domain/entities/family_activity.dart';
import '../../domain/enums/family_activity_type.dart';

class FamilyActivityModel extends FamilyActivity {
  const FamilyActivityModel({
    required super.id,
    required super.familyId,
    super.profileId,
    super.profileName,
    super.profileAvatarUrl,
    required super.type,
    required super.description,
    super.metadata,
    required super.timestamp,
  });

  factory FamilyActivityModel.fromEntity(FamilyActivity entity) {
    return FamilyActivityModel(
      id: entity.id,
      familyId: entity.familyId,
      profileId: entity.profileId,
      profileName: entity.profileName,
      profileAvatarUrl: entity.profileAvatarUrl,
      type: entity.type,
      description: entity.description,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
    );
  }

  factory FamilyActivityModel.fromJson(Map<String, dynamic> json) {
    return FamilyActivityModel(
      id: json['id']?.toString() ?? '',
      familyId: json['familyId']?.toString() ?? '',
      profileId: json['profileId']?.toString(),
      profileName: json['profileName']?.toString(),
      profileAvatarUrl: json['profileAvatarUrl']?.toString(),
      type: json['type'] != null
          ? FamilyActivityType.values.firstWhere(
              (e) => e.name == json['type'].toString(),
              orElse: () => FamilyActivityType.habitCompleted,
            )
          : FamilyActivityType.habitCompleted,
      description: json['description']?.toString() ?? '',
      metadata: json['metadata']?.toString(),
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'profileId': profileId,
      'profileName': profileName,
      'profileAvatarUrl': profileAvatarUrl,
      'type': type.name,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
