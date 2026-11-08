# Perbaikan minggu 6 ? 8 November 2026

## Implementasi

- Firebase Authentication dipertahankan. Konfigurasi Firebase tidak diganti.
- Inbox memakai SharedPreferences dengan satu key per pesan, bukan menulis ulang seluruh list. Data format lama tetap dibaca. Reload dilakukan sebelum membaca untuk menghindari cache isolate yang basi.
- Identitas delivery memakai FCM messageId, terpisah dari ID pengumuman. Pesan berbeda untuk pengumuman sama tetap menjadi dua item. Callback ulang tidak mereset status baca. Jika messageId tidak tersedia, dipakai notificationId pengirim atau fallback isi dan waktu pesan; pengirim sebaiknya menyediakan ID unik.
- Detail dimuat ke snapshot halaman, kemudian status baca disimpan setelah detail tampil. Item langsung keluar dari inbox dan badge, sementara arsip detail tetap tersedia. Status baca terpisah mencegah callback terlambat memunculkan pesan kembali.
- Badge berasal dari stream inbox. Saat resume, provider dimuat ulang untuk mengambil hasil handler background. Klik list memakai route tersimpan; query notificationId menunjuk delivery yang tepat tanpa mengganti ID pengumuman.
- Channel Android tetap campus_announcements_v2 dan suara res/raw/campus_notify.mp3. Foreground menampilkan lokal sekali untuk pesan baru. Background notification+data memakai tray sistem; data-only menampilkan lokal hanya jika handler dijalankan. Tidak ada pemutaran audio tambahan.
- Listener foreground dipasang sekali; listener rotasi token lama dibatalkan sebelum pendaftaran ulang. Callback token memakai repository, bukan ref halaman yang mungkin telah dispose.

## Login REST API dan mock jobsheet

Jobsheet menggunakan mock repository dengan delay dan string token simulasi, bukan server HTTP/API mock. Mock itu dapat mendemonstrasikan perubahan status login secara lokal tetapi tidak membuktikan request REST, validasi kredensial, refresh atau keamanan token server. Mock tidak dipasang sebagai pengganti Firebase agar login yang berjalan tetap tersedia.

Backend sungguhan masih diperlukan untuk kontrak login/refresh/logout, verifikasi token, registrasi perangkat per user, dan sinkronisasi histori inbox. Tidak ada endpoint fiktif yang ditambahkan. Dio saat ini masih helper Firebase ID token tanpa retry 401; TokenStore contoh belum dipakai oleh sesi Firebase yang dikelola SDK.

Paket messaging yang terpasang menandai getToken/onTokenRefresh deprecated dan menawarkan register/onRegistered dengan nilai FID. Alur registration token untuk pengujian Console dipertahankan secara sengaja, dengan ignore terarah dan komentar; migrasi identitas backend harus dilakukan bersama backend.

## Batasan

- SharedPreferences bukan database transaksional. Key per pesan menghindari penimpaan pesan berbeda; ini belum merupakan jaminan exactly-once lintas proses. Arsip dan status baca disimpan lokal tanpa retensi otomatis.
- Inbox masih untuk satu instalasi, belum terpisah per akun. Hindari menggunakannya untuk pesan personal antar akun sampai kontrak identitas backend tersedia.
- FCM bukan histori inbox. Jika Android tidak menjalankan handler (force-stop, pembatasan baterai, pesan notification-only tertentu), pesan yang tidak diklik mungkin belum tersimpan. Jaminan histori lengkap memerlukan penyimpanan backend dan sinkronisasi.
- Suara mengikuti izin, volume notifikasi, DND, serta pengaturan channel pengguna. Channel yang sudah dibuat tidak dapat diganti suaranya hanya dengan membuat ulang channel ID sama. Periksa pengaturan Android; reinstall/clear data untuk uji bersih akan menghapus inbox dan sesi lokal.
- Payload pengirim gunakan notification + data, data.route=/pengumuman/3 dan data.id=3. Untuk pengiriman HTTP v1, android.notification.channel_id=campus_announcements_v2 dan sound=campus_notify. Tidak perlu menambah key server di aplikasi.

## Checklist pengujian HP Android

- [ ] Full restart/install APK debug; izinkan notifikasi Android 13+. Login Firebase dengan akun yang sudah tersedia.
- [ ] Foreground: kirim 2 pesan berbeda dengan ID pengumuman sama. List dan badge bertambah dua; tiap pengiriman menghasilkan satu banner dan satu suara.
- [ ] Buka satu detail: judul/body tetap terlihat; kembali, item hilang dan badge berkurang satu. Setelah pesan terakhir dibuka, badge hilang.
- [ ] Kirim beberapa pesan berdekatan; pastikan tidak ada item hilang. Tutup/buka aplikasi melalui launcher sebelum membaca; pesan belum dibaca tetap tersedia.
- [ ] Background: tekan Home, kirim notification+data. Satu tray/suara muncul. Buka launcher tanpa klik tray dan periksa inbox; klik tray dan pastikan detail benar.
- [ ] Terminated: swipe aplikasi dari recent apps (bukan Force stop), kirim dan ketuk tray. Detail benar; inbox/badge berkurang setelah detail tampil.
- [ ] Setelah pesan dibaca, buka lagi tray lama bila masih ada; pesan tidak muncul kembali di inbox.
- [ ] Uji data-only berprioritas tinggi dari pengirim berwenang. Bila handler berjalan, muncul tray lokal sekali. Pengiriman background tetap dibatasi Android.
- [ ] Tolak izin notifikasi: aplikasi tetap berjalan; tray/suara tidak diharapkan. Izinkan kembali melalui Settings, lalu uji pesan baru.
- [ ] Periksa channel Pengumuman Kampus, volume, DND dan suara custom. Uji foreground/background/terminated secara terpisah.
- [ ] Logout/login lagi dan klik notifikasi sebelum login; tujuan detail tetap diteruskan sesudah login. Periksa juga login salah dan offline.
- [ ] Catat perangkat, versi Android, payload, state, hasil aktual dan screenshot tanpa token lengkap di docs/docs/hasil-pengujian-fcm.md.

Referensi: https://jti-polinema.github.io/flutter-codelab/06-minggu-6-authentication-security-fcm/index.html#0

## Hasil pemeriksaan otomatis

- flutter pub get: berhasil; tersedia versi paket lebih baru tetapi tidak dilakukan upgrade massal.
- flutter analyze --no-pub: No issues found.
- flutter test --no-pub: 18 test lulus. Meliputi deduplikasi, pesan bersamaan, pembacaan format lama, detail tetap terlihat, guard login dan perubahan badge 0 ? 2 ? 1.
- Widget test tidak menginisialisasi Firebase nyata; pesan debug core/no-app saat registrasi perangkat di Home adalah konsekuensi lingkungan test dan ditangani, bukan bukti kegagalan login/FCM perangkat.
- flutter build apk --debug --no-pub: berhasil. APK: build/app/outputs/flutter-apk/app-debug.apk.
- Build awal memperingatkan perbedaan versi pembaca SDK XML pada Android tooling; tidak menghalangi build.
- Tidak dilakukan commit, push atau perubahan konfigurasi GitHub. Pengujian HP belum dilakukan.

## Perbaikan lanjutan: detail tidak ditemukan

Bug berhasil direproduksi: item tersimpan dengan ID delivery berbeda dari ID pada route /pengumuman/3 tidak dapat membuka detail melalui list. Klik list sekarang selalu menambahkan notificationId dari item tersimpan, termasuk route versi lama. Pembentuk route FCM memakai helper yang sama. Test regresi dengan ID delivery berisi slash lulus; seluruh 19 test lulus. Tidak perlu menghapus data aplikasi untuk perbaikan ini. Banner lokal lama yang sudah terbit dapat menyimpan route lama; buka pesan melalui list atau uji dengan pengiriman baru.
