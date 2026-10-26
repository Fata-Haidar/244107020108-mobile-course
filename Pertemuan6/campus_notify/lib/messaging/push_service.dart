
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

/// Handler background wajib berupa fungsi top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  // Jangan melakukan navigasi di handler background.
  // Navigasi dilakukan ketika notifikasi diklik.
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

/// Menginisialisasi notifikasi lokal.
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

      if (route != null && route.startsWith('/')) {
        pendingDeepLink = route;
        onNavigate(route);
        pendingDeepLink = null;
      }
    },
  );

  final androidPlugin = _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(_channel);
}

/// Menampilkan notifikasi lokal saat aplikasi foreground.
Future<void> showForegroundNotification(
  RemoteMessage message,
) async {
  final notification = message.notification;
  final route = message.data['route']?.toString() ?? '/';

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

/// Mendaftarkan listener pesan foreground dan klik pesan background.
void listenForegroundAndOpened({
  required void Function(String route) onNavigate,
}) {
  FirebaseMessaging.onMessage.listen((message) async {
    await showForegroundNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route']?.toString() ?? '/';
    onNavigate(route);
  });
}

/// Menangani notifikasi yang membuka aplikasi dari keadaan terminated.
Future<void> handleTerminated({
  required void Function(String route) onNavigate,
}) async {
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    final route =
        initialMessage.data['route']?.toString() ?? '/';
    onNavigate(route);
    return;
  }

  final route = pendingDeepLink;
  if (route != null && route.startsWith('/')) {
    onNavigate(route);
    pendingDeepLink = null;
  }
}

/// Mengambil token FCM dan memantau perubahannya.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final messaging = FirebaseMessaging.instance;

  // Mempertahankan API sesuai contoh jobsheet.
  final token = await messaging.getToken();

  if (token != null) {
    await onToken(token);
  }

  messaging.onTokenRefresh.listen((newToken) async {
    try {
      await onToken(newToken);
    } catch (error) {
      // Pengiriman ulang token dapat ditangani sesuai kebutuhan.
    }
  });

  await messaging.subscribeToTopic('pengumuman-kampus');
}

/// Berhenti menerima broadcast topik.
Future<void> unsubscribeFromCampusAnnouncements() async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('pengumuman-kampus');
}
