import 'data/auth_repository_impl.dart';
import 'data/notification_repository_impl.dart';
import 'presentation/notification_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/push_service.dart';
import 'presentation/announcement_page.dart';
import 'presentation/home_page.dart';
import 'presentation/login_page.dart';
import 'presentation/auth_provider.dart';
import 'presentation/routes.dart';
import 'domain/campus_notification.dart';

const String loadingRoute = '/loading';

GoRouter? appRouter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      overrides: [
        registerDeviceTokenProvider.overrideWithValue(
          (onToken) => initFcmToken(onToken: onToken),
        ),
        authRepositoryProvider.overrideWith((ref) => AuthRepositoryImpl()),
        notificationRepositoryProvider.overrideWith(
          (ref) => NotificationRepositoryImpl.instance,
        ),
      ],
      child: const CampusNotifyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeNotifications();
  });
}

Future<void> _initializeNotifications() async {
  try {
    await initLocalNotifications(onNavigate: _navigateToNotificationRoute);
  } catch (e) {
    debugPrint('Local notification initialization failed: $e');
  }

  listenForegroundAndOpened(onNavigate: _navigateToNotificationRoute);

  try {
    await requestNotificationPermission();
  } catch (e) {
    debugPrint('Notification permission error: $e');
  }

  try {
    await subscribeToCampusAnnouncements();
  } catch (e) {
    debugPrint('FCM topic subscription error: $e');
  }

  // Tangani aplikasi yang dibuka melalui notifikasi.
  try {
    await handleTerminated(onNavigate: _navigateToNotificationRoute);
  } catch (e) {
    debugPrint('Initial notification handling error: $e');
  }
}

void _navigateToNotificationRoute(String route) {
  final router = appRouter;
  if (router == null) return;

  if (route.isEmpty || route == AppRoutes.home) {
    router.go(AppRoutes.home);
  } else {
    router.push(route);
  }
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        final auth = ref.read(authStateProvider);
        final location = state.matchedLocation;

        final goingLogin = location == AppRoutes.login;
        final goingLoading = location == loadingRoute;

        if (auth.isLoading) {
          return (goingLogin || goingLoading)
              ? null
              : '$loadingRoute?from=${Uri.encodeComponent(state.uri.toString())}';
        }

        final loggedIn = auth.asData?.value ?? false;

        if (!loggedIn) {
          if (goingLogin) return null;

          final destination = Uri.encodeComponent(
            goingLoading
                ? (state.uri.queryParameters['from'] ?? AppRoutes.home)
                : state.uri.toString(),
          );

          return '${AppRoutes.login}?from=$destination';
        }

        if (goingLogin || goingLoading) {
          final destination = state.uri.queryParameters['from'];

          if (destination != null && destination.startsWith('/')) {
            return destination;
          }

          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: loadingRoute,
          builder: (context, state) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),
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
              initialNotification: state.extra is CampusNotification
                  ? state.extra as CampusNotification
                  : null,
              id:
                  state.uri.queryParameters['notificationId'] ??
                  state.pathParameters['id'] ??
                  '',
            );
          },
        ),
      ],
    );

    appRouter = _router;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
      _router.refresh();
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }

  @override
  void dispose() {
    if (identical(appRouter, _router)) {
      appRouter = null;
    }

    _router.dispose();
    super.dispose();
  }
}
