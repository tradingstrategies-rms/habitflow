import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/quiet_hours_settings.dart';
import '../../domain/repositories/quiet_hours_repository.dart';
import '../models/quiet_hours_model.dart';

/// [LocalQuietHoursRepository] implements [QuietHoursRepository] using SharedPreferences.
class LocalQuietHoursRepository implements QuietHoursRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'habitflow_quiet_hours_v1';

  LocalQuietHoursRepository(this._prefs);

  @override
  Future<QuietHoursSettings> getSettings() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return QuietHoursSettings.initial();

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return QuietHoursModel.fromJson(jsonMap).toEntity();
    } catch (_) {
      return QuietHoursSettings.initial();
    }
  }

  @override
  Future<void> saveSettings(QuietHoursSettings settings) async {
    final jsonString = json.encode(QuietHoursModel.fromEntity(settings).toJson());
    await _prefs.setString(_storageKey, jsonString);
  }
}
