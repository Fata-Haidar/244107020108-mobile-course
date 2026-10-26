
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: AppRoutes.announcement,
      builder: (context, state) {
        return AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        );
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase.
  await Firebase.initializeApp();

  // 2. Daftarkan handler background sebelum runApp.
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // 3. Minta izin notifikasi.
  await requestNotificationPermission();

  // 4. Inisialisasi notifikasi lokal.
  await initLocalNotifications(
    onNavigate: (route) {
      _navigateToNotificationRoute(route);
    },
  );

  // 5. Dengarkan pesan foreground dan klik notifikasi background.
  listenForegroundAndOpened(
    onNavigate: (route) {
      _navigateToNotificationRoute(route);
    },
  );

  // 6. Berlangganan topik pengumuman kampus.
  await subscribeToCampusAnnouncements();

  // 7. Jalankan aplikasi.
  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );

  // 8. Tangani notifikasi yang membuka aplikasi dari terminated.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await handleTerminated(
      onNavigate: (route) {
        _navigateToNotificationRoute(route);
      },
    );
  });
}

/// Buka halaman tujuan tanpa mengganti halaman sebelumnya.
/// Jika route adalah '/', cukup tampilkan Home.
void _navigateToNotificationRoute(String route) {
  if (route == AppRoutes.home || route.isEmpty) {
    appRouter.go(AppRoutes.home);
    return;
  }

  appRouter.push(route);
}

class CampusNotifyApp extends StatelessWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
