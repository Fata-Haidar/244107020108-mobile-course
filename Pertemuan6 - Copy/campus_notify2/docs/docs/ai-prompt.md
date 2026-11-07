# AI Prompt Challenge — Campus Notification App

## Prompt yang digunakan

Aplikasi Flutter Campus Notification App.

Stack: `firebase_messaging`, `flutter_local_notifications`, `flutter_secure_storage`, `go_router`, dan Riverpod.

Buatkan PushService dengan fitur:
- `requestPermission`, `getToken`, dan `onTokenRefresh`, termasuk pengiriman token ke endpoint `POST /devices`.
- `onMessage` untuk menampilkan local notification secara manual.
- `onMessageOpenedApp` dan `getInitialMessage` untuk navigasi berdasarkan `data.route`.
- Subscribe dan unsubscribe topic `pengumuman-kampus`.
- Background handler top-level dengan `@pragma('vm:entry-point')`.

Tandai perbedaan konfigurasi Android 13+ dan iOS serta bagian yang tidak boleh mengakses `BuildContext`.

## Tujuan

Memastikan lifecycle token, penerimaan pesan, tampilan notifikasi, navigasi berdasarkan payload, dan topic messaging bekerja sesuai kebutuhan aplikasi.
