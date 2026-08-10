import '../../domain/entities/challenge_progress.dart';

class ChallengeProgressModel extends ChallengeProgress {
  const ChallengeProgressModel({
    required super.challengeId,
    required super.profileId,
    super.currentValue,
    super.isCompleted,
    super.completedAt,
    required super.lastUpdatedAt,
    required super.periodStartDate,
  });

  factory ChallengeProgressModel.fromEntity(ChallengeProgress entity) {
    return ChallengeProgressModel(
      challengeId: entity.challengeId,
      profileId: entity.profileId,
      currentValue: entity.currentValue,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      lastUpdatedAt: entity.lastUpdatedAt,
      periodStartDate: entity.periodStartDate,
    );
  }

  factory ChallengeProgressModel.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressModel(
      challengeId: json['challengeId']?.toString() ?? '',
      profileId: json['profileId']?.toString() ?? '',
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      periodStartDate: DateTime.parse(json['periodStartDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'profileId': profileId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'periodStartDate': periodStartDate.toIso8601String(),
    };
  }

  ChallengeProgress toEntity() => this;
}
