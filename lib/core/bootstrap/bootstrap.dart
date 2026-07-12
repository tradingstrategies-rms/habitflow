import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application_initializer.dart';

/// [Bootstrap] is the entry point for application startup.
class Bootstrap {
  static final ApplicationInitializer _initializer = ApplicationInitializer();

  /// Gets the [ApplicationInitializer] instance.
  static ApplicationInitializer get initializer => _initializer;

  /// Initializes the application and all core services.
  /// Returns a [ProviderContainer] with initialized services.
  static Future<ProviderContainer> initialize() async {
    final container = ProviderContainer();
    await _initializer.initialize(container);
    return container;
  }
}
