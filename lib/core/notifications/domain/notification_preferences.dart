import 'package:flutter/foundation.dart';
import 'notification_type.dart';

/// [NotificationPreferences] represents user settings for different notification types.
@immutable
class NotificationPreferences {
  final Map<NotificationType, bool> enabledTypes;

  const NotificationPreferences({
    this.enabledTypes = const {},
  });

  /// Checks if a specific notification type is enabled.
  /// Defaults to true if not explicitly set.
  bool isEnabled(NotificationType type) {
    return enabledTypes[type] ?? true;
  }

  NotificationPreferences copyWith({
    Map<NotificationType, bool>? enabledTypes,
  }) {
    return NotificationPreferences(
      enabledTypes: enabledTypes ?? this.enabledTypes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          mapEquals(enabledTypes, other.enabledTypes);

  @override
  int get hashCode => enabledTypes.hashCode;
}

/// [NotificationPreferencesRepository] defines the interface for persisting notification preferences.
abstract class NotificationPreferencesRepository {
  /// Loads the notification preferences.
  Future<NotificationPreferences> load();

  /// Saves the notification preferences.
  Future<void> save(NotificationPreferences preferences);
}
