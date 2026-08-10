import '../entities/quiet_hours_settings.dart';

/// [QuietHoursRepository] defines the interface for persisting quiet hours settings.
abstract class QuietHoursRepository {
  /// Retrieves the current quiet hours settings.
  Future<QuietHoursSettings> getSettings();

  /// Saves the updated quiet hours settings.
  Future<void> saveSettings(QuietHoursSettings settings);
}
