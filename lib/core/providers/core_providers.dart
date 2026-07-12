import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/core/services/storage/storage_service.dart';
import 'package:habitflow/core/services/storage/shared_preferences_storage.dart';
import 'package:habitflow/core/services/analytics/analytics_service.dart';
import 'package:habitflow/core/services/crash_reporting/crash_reporting_service.dart';
import 'package:habitflow/core/services/notifications/notification_service.dart';
import 'package:habitflow/core/services/connectivity/connectivity_service.dart';
import 'package:habitflow/core/services/permissions/permission_service.dart';
import 'package:habitflow/core/services/network/network_service.dart';
import 'package:habitflow/core/services/config/app_config.dart';
import 'package:habitflow/core/services/environment/environment.dart';
import 'package:habitflow/core/theme/theme_controller.dart'; // For SharedPreferences provider

/// Provider for [HFLogger].
final loggerProvider = Provider<HFLogger>((ref) => HFLogger());

/// Provider for [StorageService].
final storageProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesStorage(prefs);
});

/// Provider for [AnalyticsService].
final analyticsProvider = Provider<AnalyticsService>((ref) => NoOpAnalyticsService());

/// Provider for [CrashReportingService].
final crashReportingProvider = Provider<CrashReportingService>((ref) => NoOpCrashReportingService());

/// Provider for [NotificationService].
final notificationProvider = Provider<NotificationService>((ref) => NoOpNotificationService());

/// Provider for [ConnectivityService].
final connectivityProvider = Provider<ConnectivityService>((ref) => NoOpConnectivityService());

/// Provider for [PermissionService].
final permissionProvider = Provider<PermissionService>((ref) => NoOpPermissionService());

/// Provider for [NetworkService].
final networkProvider = Provider<NetworkService>((ref) => NoOpNetworkService());

/// Provider for [AppConfig].
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    appName: 'HabitFlow',
    version: '1.0.0',
    buildNumber: '1',
    environment: Environment.development,
    apiTimeout: Duration(seconds: 30),
  );
});
