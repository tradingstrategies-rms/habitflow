import '../../domain/entities/subscription.dart';
import '../../domain/enums/subscription_status.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.status,
    super.productId,
    super.expiresAt,
    super.entitlements,
  });

  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      status: entity.status,
      productId: entity.productId,
      expiresAt: entity.expiresAt,
      entitlements: entity.entitlements,
    );
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? 'free',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => SubscriptionStatus.free,
      ),
      productId: json['productId'] as String?,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      entitlements: (json['entitlements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'productId': productId,
      'expiresAt': expiresAt?.toIso8601String(),
      'entitlements': entitlements,
    };
  }
}
