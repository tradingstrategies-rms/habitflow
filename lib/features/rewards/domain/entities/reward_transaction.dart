import 'package:flutter/foundation.dart';
import '../enums/reward_type.dart';
import '../enums/reward_source.dart';

@immutable
class RewardTransaction {
  final String id;
  final String profileId;
  final int amount;
  final RewardType type;
  final RewardSource source;
  final String? referenceId; // e.g. habitId, goalId
  final String description;
  final DateTime createdAt;

  const RewardTransaction({
    required this.id,
    required this.profileId,
    required this.amount,
    required this.type,
    required this.source,
    this.referenceId,
    required this.description,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          profileId == other.profileId);

  @override
  int get hashCode => id.hashCode ^ profileId.hashCode;
}
