import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/core/services/database/firestore_service.dart';
import 'package:habitflow/core/services/storage/storage_service.dart';
import 'package:habitflow/core/services/storage/shared_preferences_storage.dart';
import 'package:habitflow/core/services/storage/cloud_storage_service.dart';
import 'package:habitflow/core/services/storage/firebase_storage_service.dart';
import 'package:habitflow/core/services/analytics/analytics_service.dart';
import 'package:habitflow/core/services/crash_reporting/crash_reporting_service.dart';
import 'package:habitflow/core/services/notifications/notification_service.dart';
import 'package:habitflow/core/services/connectivity/connectivity_service.dart';
import 'package:habitflow/core/services/permissions/permission_service.dart';
import 'package:habitflow/core/services/network/network_service.dart';
import 'package:habitflow/core/services/auth/auth_service.dart';
import 'package:habitflow/core/services/auth/firebase_auth_service.dart';
import 'package:habitflow/core/services/database/database_service.dart';
import 'package:habitflow/core/services/remote_config/remote_config_service.dart';
import 'package:habitflow/core/services/remote_config/firebase_remote_config_service.dart';
import 'package:habitflow/core/services/config/app_config.dart';
import 'package:habitflow/core/services/environment/environment.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

/// Provider for [HFLogger].
final loggerProvider = Provider<HFLogger>((ref) {
  return HFLogger(
    analytics: () => ref.read(analyticsServiceProvider),
    crashReporting: () => ref.read(crashReportingServiceProvider),
  );
});

/// Provider for Local [StorageService].
final storageProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesStorage(prefs);
});

/// Provider for [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider for [DatabaseService].
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return FirestoreService();
});

/// Provider for [CloudStorageService].
final cloudStorageServiceProvider = Provider<CloudStorageService>((ref) {
  return FirebaseStorageService();
});

/// Provider for [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Provider for [CrashReportingService].
final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return FirebaseCrashReportingService();
});

/// Provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FirebaseNotificationService();
});

/// Provider for [RemoteConfigService].
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return FirebaseRemoteConfigService();
});

/// Provider for [ConnectivityService].
final connectivityServiceProvider = Provider<ConnectivityService>((ref) => NoOpConnectivityService());

/// Provider for [PermissionService].
final permissionServiceProvider = Provider<PermissionService>((ref) => NoOpPermissionService());

/// Provider for [NetworkService].
final networkServiceProvider = Provider<NetworkService>((ref) => NoOpNetworkService());

/// Provider for [AppConfig].
final appConfigProvider = Provider<AppConfig>((ref) {
  // In a real app, this might come from a --dart-define or build configuration
  const env = Environment.development;
  return AppConfig.fromEnvironment(env);
});
