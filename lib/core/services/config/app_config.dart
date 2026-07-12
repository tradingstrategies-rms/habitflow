import '../environment/environment.dart';

/// [AppConfig] holds the configuration settings for the current [Environment].
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.environment,
    required this.apiTimeout,
    this.enableLogging = true,
    this.enableAnalytics = true,
  });

  /// The name of the application.
  final String appName;

  /// The semantic version string.
  final String version;

  /// The platform-specific build number.
  final String buildNumber;

  /// The current [Environment].
  final Environment environment;

  /// Default timeout for network requests.
  final Duration apiTimeout;

  /// Whether debug logging is enabled.
  final bool enableLogging;

  /// Whether analytics tracking is enabled.
  final bool enableAnalytics;
}
