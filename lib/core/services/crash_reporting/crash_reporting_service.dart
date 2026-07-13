// ignore_for_file: prefer_initializing_formals
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
  @override
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {dynamic reason}) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUser(String userId) async {}
}

/// [FirebaseCrashReportingService] is the Firebase Crashlytics implementation.
class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService({FirebaseCrashlytics? crashlytics}) : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;
  
  /// Lazily obtains the [FirebaseCrashlytics] instance.
  FirebaseCrashlytics get _instance => _crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {dynamic reason}) async {
    await _instance.recordError(exception, stackTrace, reason: reason);
  }

  @override
  Future<void> log(String message) async {
    await _instance.log(message);
  }

  @override
  Future<void> setUser(String userId) async {
    await _instance.setUserIdentifier(userId);
  }
}
