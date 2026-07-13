import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/core/services/analytics/analytics_service.dart';
import 'package:habitflow/core/services/crash_reporting/crash_reporting_service.dart';

class MockAnalyticsService implements AnalyticsService {
  String? lastEvent;
  Map<String, dynamic>? lastParameters;

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    lastEvent = eventName;
    lastParameters = parameters;
  }

  @override
  Future<void> logScreen(String screenName) async {}
  @override
  Future<void> setProperty(String key, String value) async {}
  @override
  Future<void> setUser(String userId) async {}
}

class MockCrashReportingService implements CrashReportingService {
  dynamic lastError;
  StackTrace? lastStack;
  dynamic lastReason;

  @override
  Future<void> recordError(dynamic exception, StackTrace? stackTrace, {dynamic reason}) async {
    lastError = exception;
    lastStack = stackTrace;
    lastReason = reason;
  }

  @override
  Future<void> log(String message) async {}
  @override
  Future<void> setUser(String userId) async {}
}

void main() {
  late HFLogger logger;
  late MockAnalyticsService mockAnalytics;
  late MockCrashReportingService mockCrashReporting;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    mockCrashReporting = MockCrashReportingService();
    logger = HFLogger(
      analytics: () => mockAnalytics,
      crashReporting: () => mockCrashReporting,
    );
  });

  group('HFLogger', () {
    test('info logs to analytics', () {
      logger.info('Test Info');
      expect(mockAnalytics.lastEvent, 'info_log');
      expect(mockAnalytics.lastParameters?['message'], 'Test Info');
    });

    test('warning logs to analytics', () {
      logger.warning('Test Warning');
      expect(mockAnalytics.lastEvent, 'warning_log');
      expect(mockAnalytics.lastParameters?['message'], 'Test Warning');
    });

    test('error logs to crash reporting', () {
      logger.error('Test Error', 'Exception', StackTrace.empty);
      expect(mockCrashReporting.lastError, 'Exception');
      expect(mockCrashReporting.lastReason, 'Test Error');
    });

    test('critical logs to crash reporting with CRITICAL prefix', () {
      logger.critical('Test Critical', 'CriticalException', StackTrace.empty);
      expect(mockCrashReporting.lastError, 'CriticalException');
      expect(mockCrashReporting.lastReason, 'CRITICAL: Test Critical');
    });
  });
}
