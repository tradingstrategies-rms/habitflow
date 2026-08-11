import 'dart:convert';
import '../../services/storage/storage_service.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_type.dart';

/// [NotificationPreferencesRepositoryImpl] implements [NotificationPreferencesRepository]
/// using a [StorageService].
class NotificationPreferencesRepositoryImpl implements NotificationPreferencesRepository {
  final StorageService _storage;
  static const _key = 'notification_preferences';

  NotificationPreferencesRepositoryImpl(this._storage);

  @override
  Future<NotificationPreferences> load() async {
    final jsonString = await _storage.read<String>(_key);
    if (jsonString == null) {
      return const NotificationPreferences();
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final Map<NotificationType, bool> enabledTypes = {};

      for (final type in NotificationType.values) {
        if (data.containsKey(type.name)) {
          enabledTypes[type] = data[type.name] as bool;
        }
      }

      return NotificationPreferences(enabledTypes: enabledTypes);
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    final Map<String, bool> data = {};
    preferences.enabledTypes.forEach((type, enabled) {
      data[type.name] = enabled;
    });

    await _storage.write(_key, jsonEncode(data));
  }
}
