import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'remote_config_service.dart';

/// [FirebaseRemoteConfigService] is the Firebase implementation of [RemoteConfigService].
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService({FirebaseRemoteConfig? remoteConfig}) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _remoteConfig.setDefaults(defaults);
  }

  @override
  String getString(String key) => _remoteConfig.getString(key);

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  int getInt(String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
