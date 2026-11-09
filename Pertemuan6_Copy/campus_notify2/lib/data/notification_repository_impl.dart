import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/campus_notification.dart';
import '../domain/notification_repository.dart';
import 'campus_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl._();

  static final NotificationRepositoryImpl instance =
      NotificationRepositoryImpl._();

  static const String _storageKey = 'campus_notifications';

  static final StreamController<List<CampusNotification>> _controller =
      StreamController<List<CampusNotification>>.broadcast();

  // One key per delivery avoids overwriting other messages across isolates.
  // Read receipts are separate and permanent: late callbacks cannot resurrect it.
  static const _messagePrefix = 'campus_message_v2_';
  static const _readPrefix = 'campus_read_v2_';

  String _key(String prefix, String id) =>
      '$prefix${base64Url.encode(utf8.encode(id))}';

  Future<SharedPreferences> _preferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs;
  }

  @override
  Future<List<CampusNotification>> getNotifications() async {
    final prefs = await _preferences();
    final messages = <String, CampusNotification>{};
    final legacy = prefs.getString(_storageKey);
    if (legacy != null) {
      for (final value in jsonDecode(legacy) as List) {
        final item = CampusNotificationModel.fromMap(
          Map<String, dynamic>.from(value as Map),
        );
        messages[item.id] = item;
      }
    }
    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_messagePrefix),
    )) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final item = CampusNotificationModel.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      messages[item.id] = item;
    }
    final items = messages.values
        .where(
          (item) =>
              !item.isRead && prefs.getBool(_key(_readPrefix, item.id)) != true,
        )
        .toList();
    items.sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
    return items;
  }

  @override
  Stream<List<CampusNotification>> watchNotifications() async* {
    // Subscribe before the initial read, so writes during startup are not lost.
    final updates = StreamController<List<CampusNotification>>();
    final subscription = _controller.stream.listen(updates.add);
    try {
      yield await getNotifications();
      yield* updates.stream;
    } finally {
      await subscription.cancel();
      await updates.close();
    }
  }

  @override
  Future<CampusNotification?> getNotification(String id) async {
    final prefs = await _preferences();
    final raw = prefs.getString(_key(_messagePrefix, id));
    if (raw != null) {
      return CampusNotificationModel.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    final legacy = prefs.getString(_storageKey);
    if (legacy != null) {
      for (final value in jsonDecode(legacy) as List) {
        final item = CampusNotificationModel.fromMap(
          Map<String, dynamic>.from(value as Map),
        );
        if (item.id == id) return item;
      }
    }
    return null;
  }

  @override
  Stream<CampusNotification?> watchNotification(String id) async* {
    yield await getNotification(id);
  }

  final Set<String> _saving = {};

  @override
  Future<bool> saveNotification({
    required String id,
    required String title,
    required String body,
    String? route,
    DateTime? createdAt,
  }) async {
    if (id.isEmpty || !_saving.add(id)) return false;
    try {
      final prefs = await _preferences();
      final key = _key(_messagePrefix, id);
      if (prefs.containsKey(key) ||
          prefs.getBool(_key(_readPrefix, id)) == true) {
        return false;
      }
      final item = CampusNotificationModel(
        id: id,
        title: title,
        body: body,
        route: route ?? '/pengumuman/${Uri.encodeComponent(id)}',
        isRead: false,
        createdAt: createdAt ?? DateTime.now(),
      );
      if (!await prefs.setString(key, jsonEncode(item.toMap()))) {
        throw StateError('Gagal menyimpan notifikasi.');
      }
      _controller.add(await getNotifications());
      return true;
    } finally {
      _saving.remove(id);
    }
  }

  @override
  Future<void> markAsRead(String id) => deleteNotification(id);

  @override
  Future<void> deleteNotification(String id) async {
    final prefs = await _preferences();
    if (!await prefs.setBool(_key(_readPrefix, id), true)) {
      throw StateError('Gagal menyimpan status baca.');
    }
    // Keep the detail archive; only remove from the unread inbox.
    _controller.add(await getNotifications());
  }

  @override
  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('campus_fcm_token', token);
  }
}
