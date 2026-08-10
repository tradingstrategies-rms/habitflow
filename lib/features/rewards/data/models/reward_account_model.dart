import '../../domain/entities/reward_account.dart';

class RewardAccountModel extends RewardAccount {
  const RewardAccountModel({
    required super.profileId,
    required super.points,
    required super.experience,
    required super.level,
    required super.lifetimeEarnings,
    required super.lastUpdatedAt,
  });

  factory RewardAccountModel.fromEntity(RewardAccount entity) {
    return RewardAccountModel(
      profileId: entity.profileId,
      points: entity.points,
      experience: entity.experience,
      level: entity.level,
      lifetimeEarnings: entity.lifetimeEarnings,
      lastUpdatedAt: entity.lastUpdatedAt,
    );
  }

  factory RewardAccountModel.fromJson(Map<String, dynamic> json) {
    return RewardAccountModel(
      profileId: json['profileId']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      lifetimeEarnings: (json['lifetimeEarnings'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? (DateTime.tryParse(json['lastUpdatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'points': points,
      'experience': experience,
      'level': level,
      'lifetimeEarnings': lifetimeEarnings,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  RewardAccount toEntity() {
    return RewardAccount(
      profileId: profileId,
      points: points,
      experience: experience,
      level: level,
      lifetimeEarnings: lifetimeEarnings,
      lastUpdatedAt: lastUpdatedAt,
    );
  }
}
