import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'application_initializer.dart';
import 'startup_tasks.dart';

/// [Bootstrap] is the entry point for application startup.
class Bootstrap {
  static final ApplicationInitializer _initializer = ApplicationInitializer();

  /// Gets the [ApplicationInitializer] instance.
  static ApplicationInitializer get initializer => _initializer;

  /// Initializes the application and all core services.
  /// Returns a [ProviderContainer] with initialized services.
  static Future<ProviderContainer> initialize() async {
    // 1. Ensure Flutter bindings are ready (Requirement 3: don't require in main.dart)
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Initialize Firebase first (Requirement 7)
    await StartupTasks.initFirebase();

    // 3. Initialize Storage before creating ProviderContainer (Requirement 1)
    final sharedPreferences = await StartupTasks.initStorage();

    // 4. Create ProviderContainer with required overrides (Requirement 2 & 3)
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );

    // 5. Initialize application services using the overridden container (Requirement 4)
    await _initializer.initialize(container);

    return container;
  }
}
