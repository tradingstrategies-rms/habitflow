import '../../domain/entities/family_circle.dart';

class FamilyCircleModel extends FamilyCircle {
  const FamilyCircleModel({
    required super.id,
    required super.name,
    required super.ownerProfileId,
    required super.createdAt,
  });

  factory FamilyCircleModel.fromEntity(FamilyCircle entity) {
    return FamilyCircleModel(
      id: entity.id,
      name: entity.name,
      ownerProfileId: entity.ownerProfileId,
      createdAt: entity.createdAt,
    );
  }

  factory FamilyCircleModel.fromJson(Map<String, dynamic> json) {
    return FamilyCircleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ownerProfileId: json['ownerProfileId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerProfileId': ownerProfileId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FamilyCircle toEntity() {
    return FamilyCircle(
      id: id,
      name: name,
      ownerProfileId: ownerProfileId,
      createdAt: createdAt,
    );
  }
}
