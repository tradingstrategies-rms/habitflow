import '../../domain/entities/family_achievement.dart';

class FamilyAchievementModel extends FamilyAchievement {
  const FamilyAchievementModel({
    required super.id,
    required super.name,
    required super.description,
    required super.icon,
    required super.targetValue,
    super.currentValue,
    super.unlockedAt,
    required super.category,
  });

  factory FamilyAchievementModel.fromEntity(FamilyAchievement entity) {
    return FamilyAchievementModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      unlockedAt: entity.unlockedAt,
      category: entity.category,
    );
  }

  factory FamilyAchievementModel.fromJson(Map<String, dynamic> json) {
    return FamilyAchievementModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 1.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      unlockedAt: json['unlockedAt'] != null
          ? (DateTime.tryParse(json['unlockedAt'].toString()))
          : null,
      category: json['category']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'category': category,
    };
  }
}
