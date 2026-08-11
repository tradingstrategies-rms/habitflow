import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_service.dart';
import '../domain/notification_type.dart';
import '../infrastructure/local_notification_service_impl.dart';
import '../infrastructure/notification_preferences_repository_impl.dart';
import '../../providers/core_providers.dart';
import 'notification_orchestrator.dart';

/// Provider for the [NotificationService] implementation.
/// We use a specific name to avoid conflict with the legacy provider in core_providers.dart.
final notificationDeliveryServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationServiceImpl();
});

/// Provider for the [NotificationPreferencesRepository].
final notificationPreferencesRepositoryProvider = Provider<NotificationPreferencesRepository>((ref) {
  final storage = ref.watch(storageProvider);
  return NotificationPreferencesRepositoryImpl(storage);
});

/// [NotificationPreferencesNotifier] manages user notification settings.
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  final NotificationPreferencesRepository _repository;

  NotificationPreferencesNotifier(this._repository) : super(const NotificationPreferences()) {
    load();
  }

  Future<void> load() async {
    state = await _repository.load();
  }

  Future<void> toggleType(NotificationType type, bool enabled) async {
    final newPreferences = state.copyWith(
      enabledTypes: {...state.enabledTypes, type: enabled},
    );
    state = newPreferences;
    await _repository.save(newPreferences);
  }
}

/// Provider for [NotificationPreferences].
final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  final repository = ref.watch(notificationPreferencesRepositoryProvider);
  return NotificationPreferencesNotifier(repository);
});

/// Provider for [NotificationOrchestrator].
final notificationOrchestratorProvider = Provider<NotificationOrchestrator>((ref) {
  final service = ref.watch(notificationDeliveryServiceProvider);
  final preferences = ref.watch(notificationPreferencesProvider);
  return NotificationOrchestrator(
    notificationService: service,
    preferences: preferences,
  );
});
