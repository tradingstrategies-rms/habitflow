import '../../domain/entities/challenge.dart';
import '../../domain/enums/challenge_type.dart';
import '../../domain/enums/challenge_difficulty.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.difficulty,
    required super.targetValue,
    required super.unit,
    required super.pointReward,
    required super.xpReward,
    required super.startDate,
    required super.endDate,
    super.relatedId,
    super.eligibleProfileIds,
    super.isRecurring,
  });

  factory ChallengeModel.fromEntity(Challenge entity) {
    return ChallengeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      difficulty: entity.difficulty,
      targetValue: entity.targetValue,
      unit: entity.unit,
      pointReward: entity.pointReward,
      xpReward: entity.xpReward,
      startDate: entity.startDate,
      endDate: entity.endDate,
      relatedId: entity.relatedId,
      eligibleProfileIds: entity.eligibleProfileIds,
      isRecurring: entity.isRecurring,
    );
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.habit,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      pointReward: (json['pointReward'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      relatedId: json['relatedId']?.toString(),
      eligibleProfileIds: (json['eligibleProfileIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'difficulty': difficulty.name,
      'targetValue': targetValue,
      'unit': unit,
      'pointReward': pointReward,
      'xpReward': xpReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'relatedId': relatedId,
      'eligibleProfileIds': eligibleProfileIds,
      'isRecurring': isRecurring,
    };
  }

  Challenge toEntity() => this;
}
