import 'package:flutter/foundation.dart';

enum SyncOperationType {
  updateAccount,
  addTransaction,
  updateChallengeProgress,
  saveRedemption,
}

@immutable
class SyncOperation {
  final String id;
  final String profileId;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  const SyncOperation({
    required this.id,
    required this.profileId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  SyncOperation copyWith({
    int? retryCount,
  }) {
    return SyncOperation(
      id: id,
      profileId: profileId,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      type: SyncOperationType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }
}
