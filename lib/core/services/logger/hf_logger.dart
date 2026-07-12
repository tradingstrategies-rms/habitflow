import 'package:flutter/foundation.dart';

/// [HFLogger] is the centralized logging service for HabitFlow.
/// 
/// It provides methods for different log levels and encapsulates the
/// underlying logging implementation (currently using [debugPrint]).
class HFLogger {
  /// Logs a debug message.
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  /// Logs an informational message.
  void info(String message) {
    _log('INFO', message);
  }

  /// Logs a warning message.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  /// Logs an error message.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
    // TODO: Integrate with CrashReportingService in later sprints
  }

  /// Logs a critical error message.
  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _log('CRITICAL', message, error, stackTrace);
    // TODO: Ensure this is reported immediately to CrashReportingService
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$level] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
