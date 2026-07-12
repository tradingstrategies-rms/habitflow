import '../environment/environment.dart';

/// [AppConfig] holds the configuration settings for the HabitFlow application.
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

  /// Factory to create environment-specific configurations.
  factory AppConfig.fromEnvironment(Environment env) {
    switch (env) {
      case Environment.development:
        return AppConfig(
          appName: 'HabitFlow (Dev)',
          packageName: 'com.habitflow.app.dev',
          version: '1.0.0',
          buildNumber: '1',
          environment: env,
          apiBaseUrl: 'https://dev.api.habitflow.com',
          apiTimeout: const Duration(seconds: 30),
        );
      case Environment.staging:
        return AppConfig(
          appName: 'HabitFlow (Staging)',
          packageName: 'com.habitflow.app.staging',
          version: '1.0.0',
          buildNumber: '1',
          environment: env,
          apiBaseUrl: 'https://staging.api.habitflow.com',
          apiTimeout: const Duration(seconds: 30),
        );
      case Environment.production:
        return AppConfig(
          appName: 'HabitFlow',
          packageName: 'com.habitflow.app',
          version: '1.0.0',
          buildNumber: '1',
          environment: env,
          apiBaseUrl: 'https://api.habitflow.com',
          apiTimeout: const Duration(seconds: 30),
        );
    }
  }

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final Environment environment;
  final String apiBaseUrl;
  final Duration apiTimeout;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enablePushNotifications;
  final bool enablePerformanceMonitoring;
  final String supportEmail;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;

  bool get isProduction => environment == Environment.production;
}
