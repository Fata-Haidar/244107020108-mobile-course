# Hasil Pengujian FCM

- Perangkat uji: Xiaomi 22101320G
- Aplikasi: `campus_notify`
- Topic: `pengumuman-kampus`
- Payload route yang diuji: `/pengumuman/3`

| App state | Prosedur pengujian | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|
| Foreground | Buka aplikasi, kirim notifikasi, lalu ketuk banner lokal | Banner muncul dan membuka `/pengumuman/3` | Belum diisi | Belum diuji |
| Background | Tekan Home, kirim notifikasi, lalu ketuk banner sistem | Aplikasi membuka `/pengumuman/3` | Belum diisi | Belum diuji |
| Terminated | Tutup aplikasi secara normal, kirim notifikasi, lalu ketuk banner | Aplikasi terbuka ke `/pengumuman/3` | Belum diisi | Belum diuji |

## Uji token lifecycle

| Pengujian | Hasil aktual | Status |
|---|---|---|
| Token awal didapatkan | Belum diisi | Belum diuji |
| Token dikirim ke `POST /devices` | Belum diisi | Belum diuji |
| Perubahan token dikirim ulang ke backend | Belum diisi | Belum diuji |
| Token tidak ditampilkan penuh pada log/screenshot | Belum diisi | Belum diuji |

## Kesimpulan

Isi bagian ini setelah semua pengujian dilakukan. Jangan menyatakan pengujian berhasil sebelum hasilnya dibuktikan pada perangkat.
