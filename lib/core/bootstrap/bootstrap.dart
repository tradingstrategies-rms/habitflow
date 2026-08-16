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
    debugPrint('Bootstrap: Entering initialize()');
    // 1. Ensure Flutter bindings are ready (Requirement 3: don't require in main.dart)
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Bootstrap: WidgetsFlutterBinding initialized');

    // 2. Initialize Firebase first (Requirement 7)
    await StartupTasks.initFirebase();
    debugPrint('Bootstrap: Firebase initialized');

    // 3. Initialize Storage before creating ProviderContainer (Requirement 1)
    final sharedPreferences = await StartupTasks.initStorage();
    debugPrint('Bootstrap: SharedPreferences initialized');

    // 4. Create ProviderContainer with required overrides (Requirement 2 & 3)
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );
    debugPrint('Bootstrap: ProviderContainer created');

    // 5. Initialize application services using the overridden container (Requirement 4)
    await _initializer.initialize(container);
    debugPrint('Bootstrap: ApplicationInitializer complete');

    return container;
  }
}
