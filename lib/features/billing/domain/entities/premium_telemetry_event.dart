import 'package:flutter/foundation.dart';
import 'premium_event_type.dart';

@immutable
class PremiumTelemetryEvent {
  final PremiumEventType type;
  final DateTime timestamp;
  final String? entitlement;
  final String? source;
  final String? profileId;

  const PremiumTelemetryEvent({
    required this.type,
    required this.timestamp,
    this.entitlement,
    this.source,
    this.profileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      if (entitlement != null) 'entitlement': entitlement,
      if (source != null) 'source': source,
      if (profileId != null) 'profileId': profileId,
    };
  }

  factory PremiumTelemetryEvent.fromJson(Map<String, dynamic> json) {
    return PremiumTelemetryEvent(
      type: PremiumEventType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      entitlement: json['entitlement'],
      source: json['source'],
      profileId: json['profileId'],
    );
  }
}
