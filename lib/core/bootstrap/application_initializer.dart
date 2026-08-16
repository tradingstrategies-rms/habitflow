import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/features/habits/application/providers/notification_router_providers.dart';
import 'package:habitflow/features/habits/application/providers/reminder_scheduler_providers.dart';

/// [ApplicationInitializer] orchestrates the startup sequence.
class ApplicationInitializer {
  /// The initialized [SharedPreferences] instance.
  late final SharedPreferences sharedPreferences;

  /// Executes the full initialization sequence.
  /// 
  /// Note: [container] is required to access initialized providers.
  Future<void> initialize(ProviderContainer container) async {
    debugPrint('ApplicationInitializer: initialize() started');
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
    debugPrint('ApplicationInitializer: RemoteConfig initialized');

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
    debugPrint('ApplicationInitializer: CrashReporting initialized');

    // 5. Notifications
    final reminderScheduler = container.read(reminderSchedulerServiceProvider);
    await reminderScheduler.initialize();
    debugPrint('ApplicationInitializer: ReminderScheduler initialized');

    final notificationRouter = container.read(notificationRouterServiceProvider);

    // Initialize new Notification Service Foundation
    final notificationService = container.read(notificationDeliveryServiceProvider);
    await notificationService.initialize((payload) {
      debugPrint('Notification tapped: ${payload.id}, route: ${payload.route}');
      notificationRouter.handleNotificationPayloadTap(payload);
    });

    debugPrint('ApplicationInitializer: Notifications initialized. Local timezone: ${tz.local.name}');
    
    logger.info('Startup sequence completed');
  }
}
