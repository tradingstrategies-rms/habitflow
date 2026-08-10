import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// [LocalNotificationAdapter] is a wrapper around flutter_local_notifications.
/// It encapsulates all notification scheduling and permission logic.
class LocalNotificationAdapter {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  /// Creates a [LocalNotificationAdapter].
  LocalNotificationAdapter({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin and timezone data.
  Future<void> initialize(void Function(String?) onNotificationTap) async {
    tz.initializeTimeZones();
    // Timezone is managed by SettingsNotifier using tz.setLocalLocation
    debugPrint('LocalNotificationAdapter: Timezones initialized.');
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap(response.payload);
      },
    );
  }

  /// Requests notification permissions from the user.
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      return await _notificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else if (Platform.isAndroid) {
      return await _notificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  /// Schedules a daily notification at the specified time.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('LocalNotificationAdapter: Scheduling daily notification');
    debugPrint('  ID: $id');
    debugPrint('  Title: $title');
    debugPrint('  Time: $time');
    debugPrint('  Scheduled Date: $scheduledDate');
    debugPrint('  Timezone: ${tz.local.name}');
    debugPrint('  Mode: inexactAllowWhileIdle');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    await _logPendingRequests();
  }

  /// Schedules a notification for a specific weekday.
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required int weekday, // 1 = Monday, 7 = Sunday
    String? payload,
  }) async {
    var scheduledDate = _nextInstanceOfWeekday(weekday, time);

    debugPrint('LocalNotificationAdapter: Scheduling weekly notification');
    debugPrint('  ID: $id');
    debugPrint('  Title: $title');
    debugPrint('  Weekday: $weekday');
    debugPrint('  Scheduled Date: $scheduledDate');
    debugPrint('  Timezone: ${tz.local.name}');
    debugPrint('  Mode: inexactAllowWhileIdle');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );

    await _logPendingRequests();
  }

  /// Schedules a one-time notification.
  Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('LocalNotificationAdapter: Scheduling one-time notification');
    debugPrint('  ID: $id');
    debugPrint('  Title: $title');
    debugPrint('  Scheduled Date: $scheduledDate');
    debugPrint('  Timezone: ${tz.local.name}');
    debugPrint('  Mode: inexactAllowWhileIdle');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    await _logPendingRequests();
  }

  /// Schedules a one-time notification at an exact [DateTime].
  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    debugPrint('LocalNotificationAdapter: Scheduling one-time exact notification');
    debugPrint('  ID: $id');
    debugPrint('  Title: $title');
    debugPrint('  Scheduled Date: $scheduledDate');
    debugPrint('  Timezone: ${tz.local.name}');
    debugPrint('  Mode: inexactAllowWhileIdle');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    await _logPendingRequests();
  }

  Future<void> _logPendingRequests() async {
    final List<PendingNotificationRequest> pendingRequests =
        await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('LocalNotificationAdapter: Total pending notifications: ${pendingRequests.length}');
    for (final request in pendingRequests) {
      debugPrint('  - ID: ${request.id}, Title: ${request.title}');
    }
  }

  /// Cancels a notification by ID.
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Notifications for habit reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // Find the next instance of the weekday
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
