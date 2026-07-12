/// [CrashReportingService] defines the interface for reporting application errors and crashes.
abstract class CrashReportingService {
  /// Records a non-fatal error.
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {dynamic reason});

  /// Logs a custom message to be included in the next crash report.
  Future<void> log(String message);

  /// Sets the user identifier for crash reports.
  Future<void> setUser(String userId);
}

/// [NoOpCrashReportingService] is a placeholder implementation.
class NoOpCrashReportingService implements CrashReportingService {
  // TODO: Implement FirebaseCrashlyticsService in Sprint 0 - Step 5
  
  @override
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {dynamic reason}) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUser(String userId) async {}
}
