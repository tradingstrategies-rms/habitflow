import 'application_initializer.dart';

/// [Bootstrap] is the entry point for application startup.
class Bootstrap {
  static final ApplicationInitializer _initializer = ApplicationInitializer();

  /// Gets the [ApplicationInitializer] instance.
  static ApplicationInitializer get initializer => _initializer;

  /// Initializes the application and all core services.
  static Future<void> initialize() async {
    await _initializer.initialize();
  }
}
