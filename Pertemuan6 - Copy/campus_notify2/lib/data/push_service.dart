import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_repository_impl.dart';
import '../domain/notification_route.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'campus_announcements_v2',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman dan informasi kampus',
  importance: Importance.high,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('campus_notify'),
);

String notificationId(RemoteMessage message) {
  if (message.messageId?.isNotEmpty == true) return message.messageId!;
  final explicit = message.data['notificationId']?.toString();
  if (explicit != null && explicit.isNotEmpty) return explicit;
  // Stable fallback; senders should always supply a unique notificationId.
  return jsonEncode([
    message.sentTime?.millisecondsSinceEpoch,
    message.data,
    message.notification?.title,
    message.notification?.body,
  ]);
}

String _notificationRoute(RemoteMessage message) {
  final target = routeFromMessage(message.data);
  final uri = Uri.tryParse(target);
  final announcement =
      uri != null &&
          uri.pathSegments.length == 2 &&
          uri.pathSegments.first == 'pengumuman'
      ? uri.pathSegments.last
      : message.data['id']?.toString();
  return AppRoutes.notificationDetail(
    id: notificationId(message),
    route: AppRoutes.announcementById(announcement ?? notificationId(message)),
  );
}

Future<bool> _saveMessage(RemoteMessage message) async {
  final notification = message.notification;

  final title =
      notification?.title ??
      message.data['title']?.toString() ??
      'Pengumuman Kampus';

  final body =
      notification?.body ??
      message.data['body']?.toString() ??
      'Ada informasi baru.';

  return NotificationRepositoryImpl.instance.saveNotification(
    id: notificationId(message),
    title: title,
    body: body,
    route: _notificationRoute(message),
    createdAt: message.sentTime,
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final inserted = await _saveMessage(message);
  // Notification payload is already displayed by Android. Only data-only
  // deliveries need a local banner from this isolate.
  if (message.notification == null && inserted) {
    await initLocalNotifications(onNavigate: (_) {});
    await _displayNotification(message);
  }
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications({
  required void Function(String route) onNavigate,
}) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');

  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        onNavigate(route);
      }
    },
  );

  final androidPlugin = _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(_channel);

  final details = await _local.getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp == true) {
    final payload = details?.notificationResponse?.payload;

    if (payload != null && payload.isNotEmpty) {
      pendingDeepLink = payload;
    }
  }
}

Future<void> showForegroundNotification(RemoteMessage message) async {
  final inserted = await _saveMessage(message);
  if (!inserted) return;

  await _displayNotification(message);
}

Future<void> _displayNotification(RemoteMessage message) async {
  final notification = message.notification;

  final title =
      notification?.title ??
      message.data['title']?.toString() ??
      'Pengumuman Kampus';

  final body =
      notification?.body ??
      message.data['body']?.toString() ??
      'Ada informasi baru.';

  await _local.show(
    id: notificationId(message).hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'campus_announcements_v2',
        'Pengumuman Kampus',
        channelDescription: 'Notifikasi pengumuman dan informasi kampus',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('campus_notify'),
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    ),
    payload: _notificationRoute(message),
  );
}

bool _listenersStarted = false;

void listenForegroundAndOpened({
  required void Function(String route) onNavigate,
}) {
  if (_listenersStarted) return;
  _listenersStarted = true;
  FirebaseMessaging.onMessage.listen((message) async {
    await showForegroundNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await _saveMessage(message);
    onNavigate(_notificationRoute(message));
  });
}

Future<void> handleTerminated({
  required void Function(String route) onNavigate,
}) async {
  final message = await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    await _saveMessage(message);
    onNavigate(_notificationRoute(message));
    return;
  }

  final route = pendingDeepLink;
  if (route != null && route.isNotEmpty) {
    onNavigate(route);
    pendingDeepLink = null;
  }
}

StreamSubscription<String>? _tokenSubscription;

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final messaging = FirebaseMessaging.instance;

  // Preserve registration-token semantics for the existing Console workflow.
  // Version 17 register/onRegistered returns FID, requiring backend migration.
  // ignore: deprecated_member_use
  final token = await messaging.getToken();
  if (token != null) {
    await onToken(token);
  }

  await _tokenSubscription?.cancel();
  // ignore: deprecated_member_use
  _tokenSubscription = messaging.onTokenRefresh.listen((newToken) async {
    try {
      await onToken(newToken);
    } catch (_) {
      // Hindari mencetak token perangkat ke log.
    }
  });
}

Future<void> subscribeToCampusAnnouncements() async {
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

Future<void> unsubscribeFromCampusAnnouncements() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
}
