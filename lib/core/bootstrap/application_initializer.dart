import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'startup_tasks.dart';

/// [ApplicationInitializer] orchestrates the startup sequence.
class ApplicationInitializer {
  /// The initialized [SharedPreferences] instance.
  late final SharedPreferences sharedPreferences;

  /// Executes the full initialization sequence.
  Future<void> initialize() async {
    // 1. Ensure Flutter bindings are ready
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Run core tasks in parallel or sequence as needed
    await StartupTasks.initLogger();
    sharedPreferences = await StartupTasks.initStorage();
    
    // 3. Optional tasks (can be async without awaiting if not critical for first frame)
    await StartupTasks.initFirebase();
    await StartupTasks.initNotifications();
  }
}
