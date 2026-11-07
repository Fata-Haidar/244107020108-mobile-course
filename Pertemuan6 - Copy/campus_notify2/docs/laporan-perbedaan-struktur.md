# Laporan Perbedaan Struktur Aplikasi

## 1. Identitas Proyek

- **Nama aplikasi:** `campus_notify`
- **Framework:** Flutter
- **Arsitektur akhir:** Clean Architecture berbasis prinsip SOLID
- **Lokasi source code:** `lib/`

## 2. Struktur Awal

Pada struktur awal, source code dikelompokkan berdasarkan jenis file secara umum:

```text
lib/
├── main.dart
├── routes.dart
├── data/
│   ├── api_client.dart
│   ├── api_errors.dart
│   ├── auth_repository.dart
│   ├── notification_repository.dart
│   └── token_store.dart
├── messaging/
│   └── push_service.dart
├── pages/
│   ├── announcement_page.dart
│   ├── home_page.dart
│   └── login_page.dart
└── providers/
    ├── auth_provider.dart
    └── notification_provider.dart
```

### Kekurangan struktur awal

1. Implementasi Firebase dan penyimpanan lokal bercampur dengan kontrak repository.
2. Entity `CampusNotification` berada di dalam repository, sehingga model domain sulit digunakan secara mandiri.
3. Halaman UI mengakses implementasi data secara langsung melalui import.
4. Folder `messaging`, `pages`, dan `providers` berdiri di luar pembagian layer aplikasi.
5. Perubahan pada Firebase atau SharedPreferences berpotensi memengaruhi bagian UI.
6. Ketergantungan antarbagian belum memiliki batas yang jelas.

## 3. Struktur Akhir Berbasis SOLID

```text
lib/
├── main.dart
├── data/
│   ├── datasources/
│   │   └── token_store.dart
│   ├── models/
│   │   └── campus_notification_model.dart
│   ├── repositories/
│   │   ├── auth_repository_impl.dart
│   │   └── notification_repository_impl.dart
│   └── services/
│       ├── api_client.dart
│       ├── api_errors.dart
│       └── push_service.dart
├── domain/
│   ├── entities/
│   │   └── campus_notification.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── notification_repository.dart
└── presentation/
    ├── pages/
    │   ├── announcement_page.dart
    │   ├── home_page.dart
    │   └── login_page.dart
    ├── providers/
    │   ├── auth_provider.dart
    │   └── notification_provider.dart
    └── routes.dart
```

## 4. Perubahan dan Pemetaan File

| Struktur awal | Struktur akhir | Perubahan |
|---|---|---|
| `data/auth_repository.dart` | `domain/repositories/auth_repository.dart` + `data/repositories/auth_repository_impl.dart` | Kontrak dipisahkan dari implementasi Firebase |
| `data/notification_repository.dart` | `domain/repositories/notification_repository.dart` + `data/repositories/notification_repository_impl.dart` | Kontrak dan penyimpanan SharedPreferences dipisahkan |
| Entity di dalam notification repository | `domain/entities/campus_notification.dart` | Entity menjadi bagian domain |
| Mapping data di repository | `data/models/campus_notification_model.dart` | Konversi Map/JSON dipindahkan ke model data |
| `messaging/push_service.dart` | `data/services/push_service.dart` | FCM dan local notification diposisikan sebagai service data |
| `pages/*.dart` | `presentation/pages/*.dart` | Halaman dikelompokkan sebagai layer presentasi |
| `providers/*.dart` | `presentation/providers/*.dart` | State management dikelompokkan sebagai layer presentasi |
| `routes.dart` | `presentation/routes.dart` | Routing menjadi bagian dari presentasi |
| `data/token_store.dart` | `data/datasources/token_store.dart` | Penyimpanan token dikategorikan sebagai sumber data |

## 5. Penerapan Prinsip SOLID

### Single Responsibility Principle

Setiap bagian memiliki satu tanggung jawab utama:

- Entity hanya merepresentasikan data bisnis.
- Model menangani serialisasi dan deserialisasi.
- Repository implementation menangani akses data.
- Provider menangani state untuk UI.
- Page menangani tampilan dan interaksi pengguna.

### Open/Closed Principle

UI bergantung pada kontrak repository. Implementasi Firebase dapat diganti dengan implementasi lain tanpa mengubah halaman dan provider.

### Liskov Substitution Principle

`AuthRepositoryImpl` dapat digunakan melalui tipe `AuthRepository`, dan `NotificationRepositoryImpl` dapat digunakan melalui tipe `NotificationRepository`.

### Interface Segregation Principle

Kontrak repository dipisahkan berdasarkan fitur autentikasi dan notifikasi, sehingga konsumen tidak perlu bergantung pada fungsi yang tidak digunakan.

### Dependency Inversion Principle

Presentation bergantung pada abstraksi di `domain`, bukan langsung pada Firebase atau SharedPreferences. Implementasi konkretnya didaftarkan melalui provider.

## 6. Perbandingan Alur Ketergantungan

### Sebelum perubahan

```text
Page
  └── Provider
        └── Repository Firebase/SharedPreferences
```

### Setelah perubahan

```text
Presentation
  └── Domain repository contract
        └── Data repository implementation
              └── Firebase / SharedPreferences / FCM
```

Dengan alur ini, dependency bergerak menuju abstraksi domain dan detail teknis berada di layer data.

## 7. Manfaat Setelah Refactor

1. Struktur proyek lebih mudah dipahami.
2. Pengujian repository dan provider lebih mudah dilakukan dengan mock atau fake implementation.
3. Perubahan teknologi penyimpanan tidak langsung memengaruhi UI.
4. Entity dan aturan bisnis dapat digunakan tanpa bergantung pada Flutter atau Firebase.
5. Penambahan fitur baru dapat dilakukan pada layer yang sesuai.
6. Risiko import silang dan ketergantungan berlebihan berkurang.

## 8. Hasil Validasi

- `dart format lib test` berhasil.
- `flutter analyze` tidak menemukan error.
- `flutter test test/auth_push_test.dart` berhasil: **9 test lulus**.
- Terdapat tiga informasi analyzer terkait API Firebase yang deprecated dan lint lama, tetapi tidak ada error kompilasi.

## 9. Kesimpulan

Struktur awal telah diubah menjadi struktur tiga layer: `data`, `domain`, dan `presentation`. Perubahan ini memisahkan aturan bisnis dari detail teknis dan UI, sehingga aplikasi `campus_notify` menjadi lebih modular, mudah diuji, dan lebih siap dikembangkan.
