import '../../domain/repositories/quiet_hours_repository.dart';

/// [QuietHoursPolicyService] implements the logic for quiet hour delivery policies.
class QuietHoursPolicyService {
  final QuietHoursRepository _repository;

  QuietHoursPolicyService(this._repository);

  /// Checks if a specific [time] falls within the configured quiet hours.
  Future<bool> isWithinQuietHours(DateTime time) async {
    final settings = await _repository.getSettings();
    if (!settings.enabled) return false;

    final start = settings.startTime;
    final end = settings.endTime;

    final currentTotalMinutes = time.hour * 60 + time.minute;
    final startTotalMinutes = start.hour * 60 + start.minute;
    final endTotalMinutes = end.hour * 60 + end.minute;

    if (startTotalMinutes <= endTotalMinutes) {
      // Same-day case (e.g., 13:00 to 15:00)
      return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes <= endTotalMinutes;
    } else {
      // Cross-midnight case (e.g., 22:00 to 08:00)
      return currentTotalMinutes >= startTotalMinutes || currentTotalMinutes <= endTotalMinutes;
    }
  }

  /// Calculates the next allowed delivery time if the given [time] is restricted.
  /// If not restricted, returns the original [time].
  Future<DateTime> nextAllowedTime(DateTime time) async {
    if (!await isWithinQuietHours(time)) return time;

    final settings = await _repository.getSettings();
    
    // The next allowed time is the end of the quiet period
    var allowed = DateTime(
      time.year,
      time.month,
      time.day,
      settings.endTime.hour,
      settings.endTime.minute,
    );

    // If the allowed time is in the past relative to the input time (because it crossed midnight), 
    // it must be tomorrow.
    if (allowed.isBefore(time)) {
      allowed = allowed.add(const Duration(days: 1));
    }

    return allowed;
  }
}
