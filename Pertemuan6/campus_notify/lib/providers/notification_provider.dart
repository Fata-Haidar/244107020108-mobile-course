
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository.instance;
});

final notificationsProvider =
    StreamProvider<List<CampusNotification>>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .watchNotifications();
});

final notificationDetailProvider =
    StreamProvider.family<CampusNotification?, String>((ref, id) {
  return ref
      .watch(notificationRepositoryProvider)
      .watchNotification(id);
});
