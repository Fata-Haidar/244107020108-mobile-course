import 'campus_notification.dart';

abstract interface class NotificationRepository {
  Future<List<CampusNotification>> getNotifications();

  Stream<List<CampusNotification>> watchNotifications();

  Future<CampusNotification?> getNotification(String id);

  Stream<CampusNotification?> watchNotification(String id);

  Future<bool> saveNotification({
    required String id,
    required String title,
    required String body,
    String? route,
    DateTime? createdAt,
  });

  Future<void> markAsRead(String id);

  Future<void> deleteNotification(String id);

  Future<void> saveDeviceToken(String token);
}
