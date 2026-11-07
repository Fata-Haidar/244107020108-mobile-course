# Daftar Perbaikan Manual

## Perbaikan yang sudah dilakukan selama praktikum

- Menambahkan konfigurasi Firebase pada project Android.
- Mengaktifkan Core Library Desugaring untuk `flutter_local_notifications`.
- Menyesuaikan pemanggilan `initialize()` dan `show()` dengan API paket yang terpasang.
- Menambahkan handler background top-level dengan `@pragma('vm:entry-point')`.
- Menambahkan penampilan local notification untuk pesan foreground.
- Menambahkan penanganan klik notifikasi melalui `onMessageOpenedApp` dan `getInitialMessage`.
- Menambahkan rute `/pengumuman/:id` menggunakan GoRouter.

## Temuan yang masih perlu diverifikasi

1. **Backend token:** fungsi pengiriman ke `POST /devices` harus dihubungkan ke API backend yang valid. Belum boleh dianggap berhasil tanpa endpoint dan respons yang teruji.
2. **Token lifecycle:** kode yang memakai `getToken()` dan `onTokenRefresh` dapat menghasilkan peringatan deprecated pada versi paket tertentu. Periksa dokumentasi versi yang terpasang sebelum migrasi API.
3. **Foreground:** pastikan banner lokal benar-benar muncul di perangkat.
4. **Klik notifikasi:** uji payload `route` pada foreground, background, dan terminated. Pastikan klik notifikasi lokal saat aplikasi terminated juga ditangani dengan benar.
5. **Keamanan:** jangan menampilkan token FCM penuh atau rahasia di log, screenshot, atau README.
6. **Android/iOS:** Android 13+ membutuhkan izin notifikasi runtime. iOS membutuhkan konfigurasi APNs dan izin yang sesuai.

## Keputusan teknis

Gunakan fungsi background hanya untuk pemrosesan ringan. Jangan mengakses `BuildContext`, melakukan navigasi, atau memakai state UI dari handler background. Navigasi dilakukan pada handler interaksi notifikasi.
