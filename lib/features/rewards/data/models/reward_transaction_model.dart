import '../../domain/entities/reward_transaction.dart';
import '../../domain/enums/reward_type.dart';
import '../../domain/enums/reward_source.dart';

class RewardTransactionModel extends RewardTransaction {
  const RewardTransactionModel({
    required super.id,
    required super.profileId,
    required super.amount,
    required super.type,
    required super.source,
    super.referenceId,
    required super.description,
    required super.createdAt,
  });

  factory RewardTransactionModel.fromEntity(RewardTransaction entity) {
    return RewardTransactionModel(
      id: entity.id,
      profileId: entity.profileId,
      amount: entity.amount,
      type: entity.type,
      source: entity.source,
      referenceId: entity.referenceId,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }

  factory RewardTransactionModel.fromJson(Map<String, dynamic> json) {
    return RewardTransactionModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profileId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: json['type'] != null
          ? RewardType.values.firstWhere(
              (e) => e.name == json['type'].toString(),
              orElse: () => RewardType.points,
            )
          : RewardType.points,
      source: json['source'] != null
          ? RewardSource.values.firstWhere(
              (e) => e.name == json['source'].toString(),
              orElse: () => RewardSource.manualAdjustment,
            )
          : RewardSource.manualAdjustment,
      referenceId: json['referenceId']?.toString(),
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'amount': amount,
      'type': type.name,
      'source': source.name,
      'referenceId': referenceId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RewardTransaction toEntity() {
    return RewardTransaction(
      id: id,
      profileId: profileId,
      amount: amount,
      type: type,
      source: source,
      referenceId: referenceId,
      description: description,
      createdAt: createdAt,
    );
  }
}
