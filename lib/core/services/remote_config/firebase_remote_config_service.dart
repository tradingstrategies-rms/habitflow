// ignore_for_file: prefer_initializing_formals
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'remote_config_service.dart';

/// [FirebaseRemoteConfigService] is the Firebase implementation of [RemoteConfigService].
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService({FirebaseRemoteConfig? remoteConfig}) : _remoteConfig = remoteConfig;

  final FirebaseRemoteConfig? _remoteConfig;
  
  /// Lazily obtains the [FirebaseRemoteConfig] instance.
  FirebaseRemoteConfig get _instance => _remoteConfig ?? FirebaseRemoteConfig.instance;

  @override
  Future<void> initialize() async {
    await _instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _instance.fetchAndActivate();
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _instance.setDefaults(defaults);
  }

  @override
  String getString(String key) => _instance.getString(key);

  @override
  bool getBool(String key) => _instance.getBool(key);

  @override
  int getInt(String key) => _instance.getInt(key);

  @override
  double getDouble(String key) => _instance.getDouble(key);
}
