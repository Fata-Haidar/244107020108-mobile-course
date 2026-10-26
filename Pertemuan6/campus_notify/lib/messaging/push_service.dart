
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

const AndroidNotificationChannel _channel =
    AndroidNotificationChannel(
  'pengumuman',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman kampus',
  importance: Importance.high,
);

/// Handler background harus berupa fungsi top-level.
/// Jangan akses BuildContext atau melakukan navigasi di sini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
}

/// Meminta izin notifikasi.
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

/// Inisialisasi notifikasi lokal dan tangani klik banner.
Future<void> initLocalNotifications({
  required void Function(String route) onNavigate,
}) async {
  const android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const ios = DarwinInitializationSettings();

  await _local.initialize(
    settings: const InitializationSettings(
      android: android,
      iOS: ios,
    ),
    onDidReceiveNotificationResponse: (response) {
      final route = routeFromMessage({
        'route': response.payload,
      });

      onNavigate(route);
    },
  );

  final androidPlugin = _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(_channel);

  // Periksa apakah aplikasi dibuka melalui notifikasi lokal.
  final launchDetails =
      await _local.getNotificationAppLaunchDetails();

  if (launchDetails?.didNotificationLaunchApp == true) {
    pendingDeepLink = routeFromMessage({
      'route':
          launchDetails?.notificationResponse?.payload,
    });
  }
}

/// Menampilkan notifikasi lokal saat aplikasi foreground.
Future<void> showForegroundNotification(
  RemoteMessage message,
) async {
  final notification = message.notification;
  final route = routeFromMessage(message.data);

  await _local.show(
    id: message.hashCode,
    title: notification?.title ?? 'Pengumuman Kampus',
    body: notification?.body ?? 'Ada pengumuman baru.',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        channelDescription: 'Notifikasi pengumuman kampus',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: route,
  );
}

/// Listener pesan foreground dan klik notifikasi background.
void listenForegroundAndOpened({
  required void Function(String route) onNavigate,
}) {
  FirebaseMessaging.onMessage.listen(
    showForegroundNotification,
  );

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    onNavigate(routeFromMessage(message.data));
  });
}

/// Menangani FCM yang membuka aplikasi dari kondisi terminated.
Future<void> handleTerminated({
  required void Function(String route) onNavigate,
}) async {
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    onNavigate(routeFromMessage(initialMessage.data));
    return;
  }

  final route = pendingDeepLink;

  if (route != null) {
    onNavigate(route);
    pendingDeepLink = null;
  }
}

/// Mengambil token awal dan mengirim token baru melalui callback.
/// Callback harus dihubungkan ke backend POST /devices.
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
      // Jangan mencetak token penuh ke log.
    }
  });

  await messaging.subscribeToTopic('pengumuman-kampus');
}

/// Berlangganan topik pengumuman kampus.
Future<void> subscribeToCampusAnnouncements() async {
  await FirebaseMessaging.instance
      .subscribeToTopic('pengumuman-kampus');
}

/// Berhenti berlangganan topik pengumuman kampus.
Future<void> unsubscribeFromCampusAnnouncements() async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('pengumuman-kampus');
}
