import 'package:flutter/foundation.dart';
import '../enums/subscription_status.dart';

@immutable
class Subscription {
  final String id;
  final SubscriptionStatus status;
  final String? productId;
  final DateTime? expiresAt;
  final List<String> entitlements;

  const Subscription({
    required this.id,
    required this.status,
    this.productId,
    this.expiresAt,
    this.entitlements = const [],
  });

  bool get isPremium => status.isPremium && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory Subscription.free() {
    return const Subscription(
      id: 'free',
      status: SubscriptionStatus.free,
      entitlements: [],
    );
  }

  Subscription copyWith({
    String? id,
    SubscriptionStatus? status,
    String? productId,
    DateTime? expiresAt,
    List<String>? entitlements,
  }) {
    return Subscription(
      id: id ?? this.id,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      expiresAt: expiresAt ?? this.expiresAt,
      entitlements: entitlements ?? this.entitlements,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          id == other.id &&
          status == other.status &&
          productId == other.productId &&
          expiresAt == other.expiresAt);

  @override
  int get hashCode =>
      id.hashCode ^ status.hashCode ^ productId.hashCode ^ expiresAt.hashCode;
}
