import '../entities/challenge.dart';
import '../enums/challenge_type.dart';

class ChallengeLifecycleService {
  /// Calculates the start date of the current period for a given challenge and date.
  DateTime calculateCurrentPeriodStart(Challenge challenge, DateTime date) {
    if (!challenge.isRecurring) {
      return challenge.startDate;
    }

    switch (challenge.type) {
      case ChallengeType.daily:
        return DateTime(date.year, date.month, date.day);
      case ChallengeType.weekly:
        // Assume week starts on Monday
        return date.subtract(Duration(days: date.weekday - 1));
      case ChallengeType.monthly:
        return DateTime(date.year, date.month, 1);
      default:
        return challenge.startDate;
    }
  }

  /// Checks if the progress for a specific period should be considered "stale" or "fresh".
  bool shouldResetProgress(DateTime progressPeriodStart, DateTime currentPeriodStart) {
    return progressPeriodStart.isBefore(currentPeriodStart);
  }

  /// Determines if a challenge is actually active for a profile at a specific time.
  bool isChallengeActive(Challenge challenge, DateTime now) {
    if (challenge.isRecurring) {
      // Recurring challenges are active as long as now is after the absolute start date
      return now.isAfter(challenge.startDate);
    }
    // Non-recurring respect the end date
    return now.isAfter(challenge.startDate) && now.isBefore(challenge.endDate);
  }
}
