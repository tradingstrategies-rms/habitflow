import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'startup_tasks.dart';

/// [ApplicationInitializer] orchestrates the startup sequence.
class ApplicationInitializer {
  /// The initialized [SharedPreferences] instance.
  late final SharedPreferences sharedPreferences;

  /// Executes the full initialization sequence.
  /// 
  /// Note: [container] is required to access initialized providers.
  Future<void> initialize(ProviderContainer container) async {
    // 1. Core tasks (Logger)
    // loggerProvider is now safe to read as Firebase was initialized in Bootstrap
    final logger = container.read(loggerProvider);
    logger.info('Startup sequence initiated');

    // 2. Storage instance is already in the container via override in Bootstrap
    sharedPreferences = container.read(sharedPreferencesProvider);
    
    // 3. Remote Config Defaults
    final remoteConfig = container.read(remoteConfigServiceProvider);
    await remoteConfig.setDefaults({
      'enable_new_habits_ui': false,
      'min_parent_pin_length': 4,
      'max_family_members': 10,
    });
    await remoteConfig.initialize();

    // 4. Global Error Handling (Crashlytics)
    final crashReporting = container.read(crashReportingServiceProvider);
    
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashReporting.recordError(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      crashReporting.recordError(error, stack);
      return true;
    };

    // 5. Notifications
    await StartupTasks.initNotifications();
    
    logger.info('Startup sequence completed');
  }
}
