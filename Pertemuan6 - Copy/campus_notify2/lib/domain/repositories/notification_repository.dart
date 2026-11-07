import '../entities/campus_notification.dart';

abstract interface class NotificationRepository {
  Future<List<CampusNotification>> getNotifications();

  Stream<List<CampusNotification>> watchNotifications();

  Stream<CampusNotification?> watchNotification(String id);

  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    String? route,
  });

  Future<void> markAsRead(String id);

  Future<void> deleteNotification(String id);

  Future<void> saveDeviceToken(String token);
}
