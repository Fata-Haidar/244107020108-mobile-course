import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campus_notify/data/notification_repository.dart';
import 'package:campus_notify/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pesan baru untuk pengumuman sama memiliki identitas berbeda', () {
    final first = RemoteMessage(messageId: 'delivery-1', data: {'id': '3'});
    final second = RemoteMessage(messageId: 'delivery-2', data: {'id': '3'});
    expect(notificationId(first), isNot(notificationId(second)));
    expect(notificationId(first), notificationId(first));
  });

  test('callback bersamaan untuk pesan sama hanya disimpan sekali', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = NotificationRepository.instance;
    final results = await Future.wait(
      List.generate(
        10,
        (_) => repo.saveNotification(id: 'same', title: 'Judul', body: 'Isi'),
      ),
    );
    expect(results.where((inserted) => inserted).length, 1);
    expect((await repo.getNotifications()).length, 1);
  });

  test('inbox lama tetap dibaca tanpa menghapus data sebelumnya', () async {
    SharedPreferences.setMockInitialValues({
      'campus_notifications':
          '[{"id":"legacy","title":"Lama","body":"Isi","route":"/pengumuman/legacy","isRead":false}]',
    });
    final repo = NotificationRepository.instance;
    expect((await repo.getNotifications()).single.id, 'legacy');
    await repo.deleteNotification('legacy');
    expect(await repo.getNotifications(), isEmpty);
    expect((await repo.getNotification('legacy'))?.title, 'Lama');
  });

  test('pesan bersamaan tidak saling menimpa', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = NotificationRepository.instance;
    await Future.wait(
      List.generate(
        20,
        (i) => repo.saveNotification(
          id: 'message-$i',
          title: 'Judul $i',
          body: 'Isi $i',
        ),
      ),
    );
    expect((await repo.getNotifications()).length, 20);
  });

  test('route dari payload FCM dinormalisasi', () {
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({}), '/');
  });

  test(
    'pesan duplikat diabaikan dan pesan dibaca tidak muncul ulang',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repo = NotificationRepository.instance;

      await repo.saveNotification(
        id: 'test-1',
        title: 'Pesan pertama',
        body: 'Isi pertama',
        route: '/pengumuman/test-1',
      );
      var notifications = await repo.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Pesan pertama');

      await repo.saveNotification(
        id: 'test-1',
        title: 'Pesan diperbarui',
        body: 'Isi terbaru',
        route: '/pengumuman/test-1',
      );
      notifications = await repo.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Pesan pertama');

      await repo.deleteNotification('test-1');
      notifications = await repo.getNotifications();
      expect(notifications, isEmpty);
      expect((await repo.getNotification('test-1'))?.body, 'Isi pertama');
      expect(
        await repo.saveNotification(
          id: 'test-1',
          title: 'Ulang',
          body: 'Ulang',
        ),
        isFalse,
      );
      expect(await repo.getNotifications(), isEmpty);
    },
  );
}
