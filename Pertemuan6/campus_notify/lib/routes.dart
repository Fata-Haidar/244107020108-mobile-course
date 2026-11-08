/// Konstanta rute aplikasi dan parser payload FCM.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/';
  static const String announcement = '/pengumuman/:id';

  static String announcementById(String id) =>
      '/pengumuman/${Uri.encodeComponent(id)}';

  /// Route pengumuman dan ID delivery adalah dua identitas berbeda.
  /// Selalu kirim ID penyimpanan, termasuk untuk route dari versi lama.
  static String notificationDetail({
    required String id,
    required String route,
  }) {
    final target = Uri.tryParse(route);
    final validAnnouncement =
        target != null &&
        target.pathSegments.length == 2 &&
        target.pathSegments.first == 'pengumuman';
    final path = validAnnouncement
        ? announcementById(target.pathSegments.last)
        : announcementById(id);
    return Uri.parse(path)
        .replace(
          queryParameters: {
            if (validAnnouncement) ...target.queryParameters,
            'notificationId': id,
          },
        )
        .toString();
  }
}

/// Fungsi murni: tidak mengakses Firebase, UI, atau BuildContext.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route'];

  if (rawRoute == null) return AppRoutes.home;

  final route = rawRoute.toString().trim();
  if (route.isEmpty) return AppRoutes.home;

  return route.startsWith('/') ? route : '/$route';
}
