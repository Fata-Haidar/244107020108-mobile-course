import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/campus_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl._();

  static final NotificationRepositoryImpl instance =
      NotificationRepositoryImpl._();

  static const String _storageKey = 'campus_notifications';

  static final StreamController<List<CampusNotification>> _controller =
      StreamController<List<CampusNotification>>.broadcast();

  @override
  Future<List<CampusNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List;

      final notifications = decoded
          .map(
            (item) => CampusNotificationModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      notifications.sort((a, b) {
        return (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        );
      });

      return notifications;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<CampusNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      notifications
          .map(
            (item) => CampusNotificationModel(
              id: item.id,
              title: item.title,
              body: item.body,
              route: item.route,
              isRead: item.isRead,
              createdAt: item.createdAt,
            ).toMap(),
          )
          .toList(),
    );

    await prefs.setString(_storageKey, encoded);

    _controller.add(notifications);
  }

  @override
  Stream<List<CampusNotification>> watchNotifications() async* {
    yield await getNotifications();
    yield* _controller.stream;
  }

  @override
  Stream<CampusNotification?> watchNotification(String id) async* {
    await for (final notifications in watchNotifications()) {
      CampusNotification? result;

      for (final item in notifications) {
        if (item.id == id) {
          result = item;
          break;
        }
      }

      yield result;
    }
  }

  @override
  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    if (id.isEmpty) return;

    final notifications = await getNotifications();

    final index = notifications.indexWhere((item) => item.id == id);

    if (index != -1) return;

    final notification = CampusNotification(
      id: id,
      title: title,
      body: body,
      route: route ?? '/pengumuman/$id',
      isRead: false,
      createdAt: DateTime.now(),
    );

    notifications.insert(0, notification);

    await _saveAll(notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();

    final index = notifications.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final item = notifications[index];
    notifications[index] = CampusNotificationModel(
      id: item.id,
      title: item.title,
      body: item.body,
      route: item.route,
      isRead: true,
      createdAt: item.createdAt,
    );

    await _saveAll(notifications);
  }

  @override
  Future<void> deleteNotification(String id) async {
    final notifications = await getNotifications();

    notifications.removeWhere((item) => item.id == id);

    await _saveAll(notifications);
  }

  @override
  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('campus_fcm_token', token);
  }
}
