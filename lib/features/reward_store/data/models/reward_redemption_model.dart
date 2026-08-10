import '../../domain/entities/reward_redemption.dart';
import '../../domain/enums/redemption_status.dart';

class RewardRedemptionModel extends RewardRedemption {
  const RewardRedemptionModel({
    required super.id,
    required super.profileId,
    required super.rewardItemId,
    required super.pointsSpent,
    required super.status,
    required super.createdAt,
  });

  factory RewardRedemptionModel.fromEntity(RewardRedemption entity) {
    return RewardRedemptionModel(
      id: entity.id,
      profileId: entity.profileId,
      rewardItemId: entity.rewardItemId,
      pointsSpent: entity.pointsSpent,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  factory RewardRedemptionModel.fromJson(Map<String, dynamic> json) {
    return RewardRedemptionModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profileId']?.toString() ?? '',
      rewardItemId: json['rewardItemId']?.toString() ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      status: RedemptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RedemptionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'rewardItemId': rewardItemId,
      'pointsSpent': pointsSpent,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RewardRedemption toEntity() => this;
}
