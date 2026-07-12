import 'package:firebase_analytics/firebase_analytics.dart';

/// [AnalyticsService] defines the interface for logging events and tracking user behavior.
abstract class AnalyticsService {
  /// Logs a screen view.
  Future<void> logScreen(String screenName);

  /// Logs a custom event.
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters});

  /// Sets the user ID.
  Future<void> setUser(String userId);

  /// Sets a user property.
  Future<void> setProperty(String key, String value);
}

/// [NoOpAnalyticsService] is a placeholder implementation.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logScreen(String screenName) async {}

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {}

  @override
  Future<void> setUser(String userId) async {}

  @override
  Future<void> setProperty(String key, String value) async {}
}

/// [FirebaseAnalyticsService] is the Firebase implementation of [AnalyticsService].
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics}) : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: eventName, 
      parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
    );
  }

  @override
  Future<void> setUser(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setProperty(String key, String value) async {
    await _analytics.setUserProperty(name: key, value: value);
  }
}
