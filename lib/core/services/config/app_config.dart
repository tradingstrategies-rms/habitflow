import '../environment/environment.dart';

/// [AppConfig] holds the configuration settings for the HabitFlow application.
/// 
/// Values vary depending on the current [Environment].
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.environment,
    required this.apiBaseUrl,
    required this.apiTimeout,
    this.enableLogging = true,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enablePushNotifications = true,
    this.enablePerformanceMonitoring = true,
    this.supportEmail = 'support@habitflow.com',
    this.privacyPolicyUrl = 'https://habitflow.com/privacy',
    this.termsOfServiceUrl = 'https://habitflow.com/terms',
  });

  /// The user-facing name of the application.
  final String appName;

  /// The unique package identifier (e.g., com.habitflow.app).
  final String packageName;

  /// The semantic version string (e.g., 1.0.0).
  final String version;

  /// The platform-specific build number.
  final String buildNumber;

  /// The current runtime environment (Dev, Staging, Prod).
  final Environment environment;

  /// The base URL for API communications.
  final String apiBaseUrl;

  /// Default timeout for network requests.
  final Duration apiTimeout;

  /// Flag for debug logging.
  final bool enableLogging;

  /// Flag for tracking user behavior.
  final bool enableAnalytics;

  /// Flag for error reporting.
  final bool enableCrashReporting;

  /// Flag for push notification services.
  final bool enablePushNotifications;

  /// Flag for performance monitoring.
  final bool enablePerformanceMonitoring;

  /// Official support contact email.
  final String supportEmail;

  /// Legal URL for privacy documentation.
  final String privacyPolicyUrl;

  /// Legal URL for terms of service.
  final String termsOfServiceUrl;

  /// Returns true if the app is running in the production environment.
  bool get isProduction => environment == Environment.production;
}
