import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/firebase_options.dart';

/// [StartupTasks] defines individual units of initialization work.
class StartupTasks {
  /// Initializes the logging system.
  static Future<HFLogger> initLogger() async {
    final logger = HFLogger();
    logger.info('Logger initialized');
    return logger;
  }

  /// Initializes local storage via [SharedPreferences].
  static Future<SharedPreferences> initStorage() async {
    return await SharedPreferences.getInstance();
  }

  /// Initializes Firebase Core using [DefaultFirebaseOptions].
  static Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Placeholder for Notification initialization.
  static Future<void> initNotifications() async {
    // TODO: Implement notification service initialization
  }
}
