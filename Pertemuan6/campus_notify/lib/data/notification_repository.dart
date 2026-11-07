
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String route;
  final bool isRead;
  final DateTime? createdAt;

  factory CampusNotification.fromMap(Map<String, dynamic> data) {
    return CampusNotification(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Pengumuman Kampus',
      body: data['body']?.toString() ?? '',
      route: data['route']?.toString() ?? '/',
      isRead: data['isRead'] == true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'route': route,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  CampusNotification copyWith({bool? isRead}) {
    return CampusNotification(
      id: id,
      title: title,
      body: body,
      route: route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository instance =
      NotificationRepository._();

  static const String _storageKey = 'campus_notifications';

  static final StreamController<List<CampusNotification>>
      _controller = StreamController<List<CampusNotification>>.broadcast();

  Future<List<CampusNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List;

      final notifications = decoded
          .map((item) => CampusNotification.fromMap(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      notifications.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return notifications;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(
    List<CampusNotification> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      notifications.map((item) => item.toMap()).toList(),
    );

    await prefs.setString(_storageKey, encoded);

    _controller.add(notifications);
  }

  Stream<List<CampusNotification>> watchNotifications() async* {
    yield await getNotifications();
    yield* _controller.stream;
  }

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

  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    if (id.isEmpty) return;

    final notifications = await getNotifications();

    final index = notifications.indexWhere(
      (item) => item.id == id,
    );

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

  Future<void> markAsRead(String id) async {
    final notifications = await getNotifications();

    final index = notifications.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) return;

    notifications[index] = notifications[index].copyWith(
      isRead: true,
    );

    await _saveAll(notifications);
  }

  Future<void> deleteNotification(String id) async {
    final notifications = await getNotifications();

    notifications.removeWhere((item) => item.id == id);

    await _saveAll(notifications);
  }

  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('campus_fcm_token', token);
  }
}
