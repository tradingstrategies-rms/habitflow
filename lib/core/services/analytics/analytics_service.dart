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

/// [NoOpAnalyticsService] is a placeholder implementation that does nothing.
class NoOpAnalyticsService implements AnalyticsService {
  // TODO: Implement FirebaseAnalyticsService in Sprint 0 - Step 5
  
  @override
  Future<void> logScreen(String screenName) async {}

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {}

  @override
  Future<void> setUser(String userId) async {}

  @override
  Future<void> setProperty(String key, String value) async {}
}
