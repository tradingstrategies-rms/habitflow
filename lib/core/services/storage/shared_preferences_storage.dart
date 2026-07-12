import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// [SharedPreferencesStorage] is the [SharedPreferences] implementation of [StorageService].
class SharedPreferencesStorage implements StorageService {
  SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<T?> read<T>(String key) async {
    if (T == String) return _prefs.getString(key) as T?;
    if (T == bool) return _prefs.getBool(key) as T?;
    if (T == int) return _prefs.getInt(key) as T?;
    if (T == double) return _prefs.getDouble(key) as T?;
    if (T == List<String>) return _prefs.getStringList(key) as T?;
    return _prefs.get(key) as T?;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw UnsupportedError('Unsupported type ${value.runtimeType} for SharedPreferences');
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> contains(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
