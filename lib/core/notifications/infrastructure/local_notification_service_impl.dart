import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_payload.dart';
import '../domain/notification_priority.dart';
import '../domain/notification_service.dart';

/// [LocalNotificationServiceImpl] implements [NotificationService] using flutter_local_notifications.
class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationServiceImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize(void Function(NotificationPayload) onNotificationTap) async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            final payload = NotificationPayload.fromJson(data);
            onNotificationTap(payload);
          } catch (_) {
            // Fallback or ignore
          }
        }
      },
    );
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    bool? granted = false;
    if (Platform.isIOS) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      granted = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    return granted == true ? NotificationPermissionStatus.granted : NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    // For simplicity, we just return denied if not explicitly granted in some cases,
    // but flutter_local_notifications doesn't have a direct "get current status" 
    // that returns the enum easily across all platforms without native code.
    // We'll approximate or assume granted for now if we can't determine.
    return NotificationPermissionStatus.notDetermined;
  }

  @override
  Future<void> deliver(NotificationPayload payload) async {
    final androidDetails = AndroidNotificationDetails(
      payload.type.name,
      payload.type.name, // In a real app, use localized/friendly names
      importance: _mapToImportance(payload.priority),
      priority: _mapToPriority(payload.priority),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    if (payload.scheduledAt == null) {
      await _plugin.show(
        payload.intId,
        payload.title,
        payload.body,
        notificationDetails,
        payload: _encodePayload(payload),
      );
    } else {
      await _plugin.zonedSchedule(
        payload.intId,
        payload.title,
        payload.body,
        tz.TZDateTime.from(payload.scheduledAt!, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _encodePayload(payload),
      );
    }
  }

  @override
  Future<void> cancel(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Importance _mapToImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.max;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
    }
  }

  Priority _mapToPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
    }
  }

  String _encodePayload(NotificationPayload payload) {
    return jsonEncode(payload.toJson());
  }
}
