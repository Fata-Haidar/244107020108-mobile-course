import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification_repository.dart';
import '../domain/campus_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  throw StateError('NotificationRepository harus disediakan di ProviderScope.');
});

final notificationsProvider = StreamProvider<List<CampusNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final notificationDetailProvider =
    StreamProvider.family<CampusNotification?, String>((ref, id) {
      return ref.watch(notificationRepositoryProvider).watchNotification(id);
    });

/// Disediakan oleh composition root agar UI tidak mengimpor Firebase.
final registerDeviceTokenProvider =
    Provider<Future<void> Function(Future<void> Function(String) onToken)>((
      ref,
    ) {
      throw StateError('Registrasi token harus disediakan di ProviderScope.');
    });
