# Laporan Perbedaan Struktur Aplikasi

Isi terbaru Pertemuan6/campus_notify disalin ke Pertemuan6 - Copy/campus_notify2.
Folder sumber tetap tersedia.

## Struktur lib

Semua file langsung berada dalam tiga folder berikut, tanpa subfolder tambahan.

```text
lib/
|-- data/
|   |-- api_client.dart
|   |-- api_errors.dart
|   |-- auth_repository_impl.dart
|   |-- campus_notification_model.dart
|   |-- notification_repository_impl.dart
|   |-- push_service.dart
|   |-- token_store.dart
|-- domain/
|   |-- auth_repository.dart
|   |-- campus_notification.dart
|   |-- notification_repository.dart
|   |-- notification_route.dart
|-- presentation/
|   |-- announcement_page.dart
|   |-- auth_provider.dart
|   |-- home_page.dart
|   |-- login_page.dart
|   |-- notification_provider.dart
|   |-- routes.dart
`-- main.dart
```

## Pembagian tanggung jawab

- Data: implementasi repository, model serialisasi, penyimpanan token, API, dan layanan push.
- Domain: entity, kontrak repository, dan aturan tujuan notifikasi.
- Presentation: halaman, provider Riverpod, dan ekspor rute.
- main.dart: inisialisasi dan penghubung kontrak dengan implementasi melalui ProviderScope.

Domain tidak bergantung pada Flutter, Firebase, data, atau presentation. UI dan provider menggunakan kontrak domain; implementasi data disediakan di main.dart.

Perilaku login, badge, detail notifikasi, penanganan pesan duplikat dan bersamaan, serta arsip pesan dibaca tetap dipertahankan.
