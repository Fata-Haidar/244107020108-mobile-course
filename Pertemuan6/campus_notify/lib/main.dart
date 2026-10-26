
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/pengumuman/:id',
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

  await Firebase.initializeApp();

  // Daftarkan handler background sebelum runApp.
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // Minta izin notifikasi.
  await requestNotificationPermission();

  // Siapkan notifikasi lokal dan penanganan klik.
  await initLocalNotifications(
    onNavigate: (route) {
      appRouter.go(route);
    },
  );

  // Listener foreground dan klik notifikasi background.
  listenForegroundAndOpened(
    onNavigate: (route) {
      appRouter.go(route);
    },
  );

  // Langganan broadcast pengumuman kampus.
  await FirebaseMessaging.instance
      .subscribeToTopic('pengumuman-kampus');

  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );

  // Periksa apakah aplikasi dibuka melalui notifikasi
  // ketika sebelumnya berada dalam keadaan terminated.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await handleTerminated(
      onNavigate: (route) {
        appRouter.go(route);
      },
    );
  });
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
