import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../../features/settings/application/settings_notifier.dart';

class DateTimeUtils {
  final SettingsState _settings;

  DateTimeUtils(this._settings);

  tz.Location get _location {
    return tz.getLocation(_settings.selectedCountry.timezone);
  }

  tz.TZDateTime now() {
    return tz.TZDateTime.now(_location);
  }

  tz.TZDateTime fromUtc(DateTime utcDateTime) {
    return tz.TZDateTime.from(utcDateTime.isUtc ? utcDateTime : utcDateTime.toUtc(), _location);
  }

  DateTime toUtc(tz.TZDateTime localDateTime) {
    return localDateTime.toUtc();
  }

  String formatDate(DateTime dateTime, {String format = 'MMM dd, yyyy'}) {
    final local = fromUtc(dateTime);
    return DateFormat(format).format(local);
  }

  String formatTime(DateTime dateTime, {String format = 'HH:mm'}) {
    final local = fromUtc(dateTime);
    return DateFormat(format).format(local);
  }

  String formatDateTime(DateTime dateTime) {
    return "${formatDate(dateTime)} ${formatTime(dateTime)}";
  }
}

final dateTimeUtilsProvider = Provider<DateTimeUtils>((ref) {
  final settings = ref.watch(settingsProvider);
  return DateTimeUtils(settings);
});
