import '../../domain/entities/reward_item.dart';
import '../../domain/enums/reward_category.dart';

class RewardItemModel extends RewardItem {
  const RewardItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.pointsCost,
    required super.category,
    super.isAvailable,
    super.imageUrl,
    super.eligibleProfileIds,
  });

  factory RewardItemModel.fromEntity(RewardItem entity) {
    return RewardItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      pointsCost: entity.pointsCost,
      category: entity.category,
      isAvailable: entity.isAvailable,
      imageUrl: entity.imageUrl,
      eligibleProfileIds: entity.eligibleProfileIds,
    );
  }

  factory RewardItemModel.fromJson(Map<String, dynamic> json) {
    return RewardItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      category: RewardCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RewardCategory.other,
      ),
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl']?.toString(),
      eligibleProfileIds: (json['eligibleProfileIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'category': category.name,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'eligibleProfileIds': eligibleProfileIds,
    };
  }

  RewardItem toEntity() => this;
}
