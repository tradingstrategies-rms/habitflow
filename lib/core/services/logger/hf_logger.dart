// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:habitflow/core/services/analytics/analytics_service.dart';
import 'package:habitflow/core/services/crash_reporting/crash_reporting_service.dart';

/// [HFLogger] is the centralized logging service for HabitFlow.
class HFLogger {
  HFLogger({
    AnalyticsService? analytics,
    CrashReportingService? crashReporting,
  })  : _analytics = analytics,
        _crashReporting = crashReporting;

  final AnalyticsService? _analytics;
  final CrashReportingService? _crashReporting;

  /// Logs a debug message.
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  /// Logs an informational message.
  void info(String message) {
    _log('INFO', message);
    _analytics?.logEvent('info_log', parameters: {'message': message});
  }

  /// Logs a warning message.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
    _analytics?.logEvent('warning_log', parameters: {'message': message});
  }

  /// Logs an error message.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
    _crashReporting?.recordError(error ?? message, stackTrace, reason: message);
  }

  /// Logs a critical error message.
  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _log('CRITICAL', message, error, stackTrace);
    _crashReporting?.recordError(error ?? message, stackTrace, reason: 'CRITICAL: $message');
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$level] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
