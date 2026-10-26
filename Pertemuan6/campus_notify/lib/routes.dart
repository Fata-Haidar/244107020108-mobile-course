
/// Konstanta rute aplikasi dan parser payload FCM.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementById(String id) =>
      '/pengumuman/$id';
}

/// Fungsi murni: tidak mengakses Firebase, UI, atau BuildContext.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route'];

  if (rawRoute == null) return AppRoutes.home;

  final route = rawRoute.toString().trim();
  if (route.isEmpty) return AppRoutes.home;

  return route.startsWith('/') ? route : '/$route';
}
