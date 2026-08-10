import 'package:flutter/foundation.dart';
import '../enums/redemption_status.dart';

@immutable
class RewardRedemption {
  final String id;
  final String profileId;
  final String rewardItemId;
  final int pointsSpent;
  final RedemptionStatus status;
  final DateTime createdAt;

  const RewardRedemption({
    required this.id,
    required this.profileId,
    required this.rewardItemId,
    required this.pointsSpent,
    required this.status,
    required this.createdAt,
  });

  RewardRedemption copyWith({
    RedemptionStatus? status,
  }) {
    return RewardRedemption(
      id: id,
      profileId: profileId,
      rewardItemId: rewardItemId,
      pointsSpent: pointsSpent,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardRedemption &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
