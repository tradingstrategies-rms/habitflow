import 'package:flutter/foundation.dart';
import '../enums/reward_type.dart';

@immutable
class RewardDefinition {
  final String id;
  final String name;
  final String description;
  final int value;
  final RewardType type;
  final String icon;

  const RewardDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.type,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
