
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/notification_repository.dart';
import '../routes.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

const AndroidNotificationChannel _channel =
    AndroidNotificationChannel(
  'campus_announcements_v2',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman dan informasi kampus',
  importance: Importance.high,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('campus_notify'),
);

String _notificationId(RemoteMessage message) {
  final data = message.data;

  final id = data['notificationId']?.toString();
  if (id != null && id.isNotEmpty) return id;

  final announcementId = data['announcementId']?.toString();
  if (announcementId != null && announcementId.isNotEmpty) {
    return announcementId;
  }

  final route = data['route']?.toString();
  if (route != null) {
    final uri = Uri.tryParse(route);
    if (uri != null &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'pengumuman') {
      return uri.pathSegments[1];
    }
  }

  return message.messageId ??
      DateTime.now().microsecondsSinceEpoch.toString();
}

String _notificationRoute(RemoteMessage message) {
  final route = message.data['route']?.toString();

  if (route != null && route.isNotEmpty) {
    return routeFromMessage(message.data);
  }

  return AppRoutes.announcementById(_notificationId(message));
}

Future<void> _saveMessage(RemoteMessage message) async {
  final notification = message.notification;

  final title = notification?.title ??
      message.data['title']?.toString() ??
      'Pengumuman Kampus';

  final body = notification?.body ??
      message.data['body']?.toString() ??
      'Ada informasi baru.';

  await NotificationRepository.instance.saveNotification(
    id: _notificationId(message),
    title: title,
    body: body,
    route: _notificationRoute(message),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
  await _saveMessage(message);
}

Future<bool> requestNotificationPermission() async {
  final settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  return settings.authorizationStatus ==
          AuthorizationStatus.authorized ||
      settings.authorizationStatus ==
          AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications({
  required void Function(String route) onNavigate,
}) async {
  const android = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(
      android: android,
      iOS: ios,
    ),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        onNavigate(route);
      }
    },
  );

  final androidPlugin = _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(_channel);

  final details = await _local.getNotificationAppLaunchDetails();

  if (details?.didNotificationLaunchApp == true) {
    final payload = details?.notificationResponse?.payload;

    if (payload != null && payload.isNotEmpty) {
      pendingDeepLink = payload;
    }
  }
}

Future<void> showForegroundNotification(
  RemoteMessage message,
) async {
  await _saveMessage(message);

  final notification = message.notification;

  final title = notification?.title ??
      message.data['title']?.toString() ??
      'Pengumuman Kampus';

  final body = notification?.body ??
      message.data['body']?.toString() ??
      'Ada informasi baru.';

  await _local.show(
    id: _notificationId(message).hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'campus_announcements_v2',
        'Pengumuman Kampus',
        channelDescription:
            'Notifikasi pengumuman dan informasi kampus',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          'campus_notify',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    ),
    payload: _notificationRoute(message),
  );
}

void listenForegroundAndOpened({
  required void Function(String route) onNavigate,
}) {
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
  final message =
      await FirebaseMessaging.instance.getInitialMessage();

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

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final messaging = FirebaseMessaging.instance;

  final token = await messaging.getToken();
  if (token != null) {
    await onToken(token);
  }

  messaging.onTokenRefresh.listen((newToken) async {
    try {
      await onToken(newToken);
    } catch (_) {
      // Hindari mencetak token perangkat ke log.
    }
  });
}

Future<void> subscribeToCampusAnnouncements() async {
  await FirebaseMessaging.instance
      .subscribeToTopic('pengumuman-kampus');
}

Future<void> unsubscribeFromCampusAnnouncements() async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('pengumuman-kampus');
}
