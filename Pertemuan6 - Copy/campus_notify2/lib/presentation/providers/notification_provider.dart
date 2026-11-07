import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl.instance;
});

final notificationsProvider = StreamProvider<List<CampusNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final notificationDetailProvider =
    StreamProvider.family<CampusNotification?, String>((ref, id) {
      return ref.watch(notificationRepositoryProvider).watchNotification(id);
    });
