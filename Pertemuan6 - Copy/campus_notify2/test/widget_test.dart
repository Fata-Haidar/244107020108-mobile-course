import 'package:campus_notify/presentation/notification_provider.dart';
import 'package:campus_notify/domain/campus_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_notify/main.dart';
import 'package:campus_notify/presentation/auth_provider.dart';
import 'package:campus_notify/presentation/announcement_page.dart';
import 'package:campus_notify/data/notification_repository_impl.dart';

class LoggedIn extends AuthNotifier {
  @override
  Future<bool> build() async => true;
}

class LoggedOut extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('belum login diarahkan ke form login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            NotificationRepositoryImpl.instance,
          ),
          registerDeviceTokenProvider.overrideWithValue((onToken) async {}),
          authStateProvider.overrideWith(LoggedOut.new),
        ],
        child: const CampusNotifyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();
    expect(find.text('Email wajib diisi'), findsOneWidget);
  });

  testWidgets('badge mengikuti pesan masuk dan pesan dibuka', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = NotificationRepositoryImpl.instance;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            NotificationRepositoryImpl.instance,
          ),
          registerDeviceTokenProvider.overrideWithValue((onToken) async {}),
          authStateProvider.overrideWith(LoggedIn.new),
        ],
        child: const CampusNotifyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifikasi (0 belum dibaca)'), findsOneWidget);
    await repo.saveNotification(id: 'badge-a', title: 'Pesan A', body: 'Isi A');
    await repo.saveNotification(id: 'badge-b', title: 'Pesan B', body: 'Isi B');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifikasi (2 belum dibaca)'), findsOneWidget);
    await tester.tap(find.text('Pesan A'));
    await tester.pumpAndSettle();
    expect((await repo.getNotifications()).length, 1);
    expect(find.text('Isi A'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifikasi (1 belum dibaca)'), findsOneWidget);
  });

  testWidgets(
    'detail memakai ID pesan meskipun route menyimpan ID pengumuman',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = NotificationRepositoryImpl.instance;
      await repo.saveNotification(
        id: '0:delivery/123',
        title: 'Pesan route lama',
        body: 'Detail lengkap pesan lama',
        route: '/pengumuman/3',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(
              NotificationRepositoryImpl.instance,
            ),
            registerDeviceTokenProvider.overrideWithValue((onToken) async {}),
            authStateProvider.overrideWith(LoggedIn.new),
          ],
          child: const CampusNotifyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pesan route lama'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Notifikasi'), findsOneWidget);
      expect(find.text('Detail lengkap pesan lama'), findsOneWidget);
      expect(find.text('Notifikasi tidak ditemukan.'), findsNothing);
      expect(await repo.getNotifications(), isEmpty);
    },
  );

  testWidgets(
    'detail snapshot tetap tampil saat lookup penyimpanan tidak cocok',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      const message = CampusNotification(
        id: 'old-message',
        title: 'Pesan lama',
        body: 'Isi dari list',
        route: '/pengumuman/3',
        isRead: false,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(
              NotificationRepositoryImpl.instance,
            ),
          ],
          child: const MaterialApp(
            home: AnnouncementPage(id: '3', initialNotification: message),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Isi dari list'), findsOneWidget);
      expect(find.text('Notifikasi tidak ditemukan.'), findsNothing);
      // Receipt uses the actual message ID, not the route's announcement ID.
      expect(
        await NotificationRepositoryImpl.instance.saveNotification(
          id: 'old-message',
          title: 'Ulang',
          body: 'Ulang',
        ),
        isFalse,
      );
      expect(
        await NotificationRepositoryImpl.instance.saveNotification(
          id: '3',
          title: 'Pesan lain',
          body: 'Lain',
        ),
        isTrue,
      );
    },
  );

  testWidgets('detail tetap tampil setelah item keluar dari inbox', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = NotificationRepositoryImpl.instance;
    await repo.saveNotification(
      id: 'detail',
      title: 'Judul detail',
      body: 'Isi detail',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            NotificationRepositoryImpl.instance,
          ),
        ],
        child: const MaterialApp(home: AnnouncementPage(id: 'detail')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Judul detail'), findsOneWidget);
    expect(find.text('Isi detail'), findsOneWidget);
    expect(await repo.getNotifications(), isEmpty);
    expect((await repo.getNotification('detail'))?.title, 'Judul detail');
  });
}
