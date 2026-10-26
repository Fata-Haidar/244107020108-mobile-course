
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

/// Meminta izin notifikasi.
Future<bool> requestNotificationPermission() async {
  final settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );

  return settings.authorizationStatus ==
          AuthorizationStatus.authorized ||
      settings.authorizationStatus ==
          AuthorizationStatus.provisional;
}

/// Menginisialisasi notifikasi lokal.
Future<void> initLocalNotifications() async {
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
      pendingDeepLink = response.payload;
    },
  );
}

/// Mengambil token FCM dan memantau perubahan token.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final messaging = FirebaseMessaging.instance;

  // Mengambil token saat ini.
  final token = await messaging.getToken();

  if (token != null) {
    await onToken(token);
  }

  // Memantau perubahan token.
  messaging.onTokenRefresh.listen((newToken) async {
    try {
      await onToken(newToken);
    } catch (error) {
      // Penanganan kegagalan pengiriman token.
    }
  });

  // Berlangganan topik pengumuman kampus.
  await messaging.subscribeToTopic('pengumuman-kampus');
}

/// Menampilkan notifikasi ketika aplikasi sedang terbuka.
Future<void> showForegroundNotification(
  RemoteMessage message,
) async {
  final notification = message.notification;

  if (notification == null) return;

  const androidDetails = AndroidNotificationDetails(
    'campus_notifications',
    'Pengumuman Kampus',
    channelDescription: 'Notifikasi pengumuman kampus',
    importance: Importance.high,
    priority: Priority.high,
  );

  const iosDetails = DarwinNotificationDetails();

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _local.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: notificationDetails,
    payload: message.data.isEmpty
        ? null
        : message.data.toString(),
  );
}
