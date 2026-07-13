// ignore_for_file: prefer_initializing_formals
import 'package:firebase_messaging/firebase_messaging.dart';

/// [NotificationService] defines the interface for local and push notifications.
abstract class NotificationService {
  /// Initializes the notification service.
  Future<void> initialize();

  /// Schedules a local notification.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Cancels a specific notification by ID.
  Future<void> cancel(int id);

  /// Cancels all scheduled notifications.
  Future<void> cancelAll();

  /// Requests permission to show notifications.
  Future<bool> requestPermission();

  /// Gets the FCM token.
  Future<String?> getToken();
}

/// [NoOpNotificationService] is a placeholder implementation.
class NoOpNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => null;
}

/// [FirebaseNotificationService] handles push notifications via Firebase Messaging.
class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService({FirebaseMessaging? messaging}) : _messaging = messaging;

  final FirebaseMessaging? _messaging;
  
  /// Lazily obtains the [FirebaseMessaging] instance.
  FirebaseMessaging get _instance => _messaging ?? FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground message
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when app is in background but opened
    });
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // TODO: Implement local scheduling with flutter_local_notifications
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool> requestPermission() async {
    final settings = await _instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<String?> getToken() async {
    return await _instance.getToken();
  }
}
