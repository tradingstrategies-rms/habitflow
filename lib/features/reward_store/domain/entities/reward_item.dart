import 'package:flutter/foundation.dart';
import '../enums/reward_category.dart';

@immutable
class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final RewardCategory category;
  final bool isAvailable;
  final String? imageUrl;
  final List<String> eligibleProfileIds; // Empty list means all

  const RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.category,
    this.isAvailable = true,
    this.imageUrl,
    this.eligibleProfileIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardItem &&
          runtimeType == other.runtimeType &&
          id == other.id);

  @override
  int get hashCode => id.hashCode;
}
