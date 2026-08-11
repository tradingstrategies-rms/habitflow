import 'package:flutter/foundation.dart';
import 'notification_priority.dart';
import 'notification_type.dart';

/// [NotificationPayload] is a platform-independent representation of a notification.
@immutable
class NotificationPayload {
  /// Unique and stable identifier for this notification.
  /// Used for deduplication and cancellation.
  final String id;

  /// The title of the notification.
  final String title;

  /// The body text of the notification.
  final String body;

  /// The category/type of the notification.
  final NotificationType type;

  /// The priority of the notification.
  final NotificationPriority priority;

  /// Optional date and time when the notification should be delivered.
  /// If null, the notification is shown immediately.
  final DateTime? scheduledAt;

  /// Optional navigation target (deep link) when the notification is tapped.
  final String? route;

  /// Optional metadata for the notification.
  final Map<String, String>? metadata;

  /// Optional profile ID of the recipient.
  final String? recipientProfileId;

  /// Optional family ID associated with the notification.
  final String? familyId;

  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.scheduledAt,
    this.route,
    this.metadata,
    this.recipientProfileId,
    this.familyId,
  });

  /// Creates a [NotificationPayload] from a JSON map.
  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      route: json['route'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      recipientProfileId: json['recipientProfileId'] as String?,
      familyId: json['familyId'] as String?,
    );
  }

  /// Converts this payload to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'route': route,
      'metadata': metadata,
      'recipientProfileId': recipientProfileId,
      'familyId': familyId,
    };
  }

  /// Converts the string ID to an integer for platform notification APIs.
  int get intId => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          type == other.type &&
          priority == other.priority &&
          scheduledAt == other.scheduledAt &&
          route == other.route &&
          recipientProfileId == other.recipientProfileId &&
          familyId == other.familyId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      body.hashCode ^
      type.hashCode ^
      priority.hashCode ^
      scheduledAt.hashCode ^
      route.hashCode ^
      recipientProfileId.hashCode ^
      familyId.hashCode;
}
