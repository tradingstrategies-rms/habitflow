/// [RemoteConfigService] defines the interface for remote configuration.
abstract class RemoteConfigService {
  /// Initializes the service and fetches/activates values.
  Future<void> initialize();

  /// Sets default values for remote config.
  Future<void> setDefaults(Map<String, dynamic> defaults);

  /// Gets a string value from remote config.
  String getString(String key);

  /// Gets a boolean value from remote config.
  bool getBool(String key);

  /// Gets an integer value from remote config.
  int getInt(String key);

  /// Gets a double value from remote config.
  double getDouble(String key);
}

/// [NoOpRemoteConfigService] is a placeholder for development.
class NoOpRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {}

  @override
  String getString(String key) => '';

  @override
  bool getBool(String key) => false;

  @override
  int getInt(String key) => 0;

  @override
  double getDouble(String key) => 0.0;
}
