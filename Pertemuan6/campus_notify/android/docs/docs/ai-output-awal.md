# Output Awal AI

Draf awal AI mencakup:
1. Permintaan izin notifikasi.
2. Pengambilan token FCM dan pemantauan perubahan token.
3. Pengiriman token ke backend melalui `POST /devices`.
4. Penampilan notifikasi lokal ketika aplikasi menerima pesan dalam keadaan foreground.
5. Navigasi dari `onMessageOpenedApp` dan `getInitialMessage` berdasarkan `data.route`.
6. Subscribe dan unsubscribe topik `pengumuman-kampus`.
7. Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`.

Catatan: dokumen ini merangkum keluaran awal yang diminta oleh prompt, bukan transkrip kode lengkap. Simpan salinan kode AI awal yang benar-benar digunakan jika dosen meminta bukti output asli.
