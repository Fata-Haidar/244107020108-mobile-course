# LAPORAN PRAKTIKUM PEMROGRAMAN MOBILE

**Topik:** Pengesetan Ekosistem Flutter, Android SDK, ADB, & Debugging Aplikasi Pertama
**Mata Kuliah:** Pemrograman Mobile — Pertemuan 1

---

## DATA MAHASISWA

| Keterangan         | Data                         |
| ------------------ | ---------------------------- |
| **Nama Mahasiswa** | Fata Haidar Aly              |
| **NIM**            | 244107020108                 |
| **Mata Kuliah**    | Pemrograman Mobile           |
| **Pertemuan**      | Minggu 1 — Ecosystem & Setup |

---

# I. TUJUAN PRAKTIKUM

Praktikum ini bertujuan untuk:

1. Melakukan instalasi Package Manager Chocolatey pada sistem operasi Windows.
2. Melakukan instalasi Dart SDK dan Flutter SDK melalui Chocolatey CLI.
3. Melakukan instalasi Visual Studio Code beserta ekstensi pendukung Flutter dan Dart.
4. Melakukan instalasi Android Studio, Android SDK, Build-Tools, dan Platform-Tools (ADB).
5. Melakukan konfigurasi lisensi dan komponen Android SDK.
6. Melakukan konfigurasi variabel lingkungan (*Environment Variables*) pada Windows.
7. Melakukan konfigurasi keamanan Git menggunakan `safe.directory`.
8. Menghubungkan perangkat Android fisik melalui USB Debugging dan ADB.
9. Membuat project Flutter pertama.
10. Menyusun dan memahami kode program pada `lib/main.dart`.
11. Melakukan proses build dan debugging aplikasi Flutter.
12. Menjalankan aplikasi Flutter pada perangkat Android fisik.

---

# III. LANGKAH-LANGKAH KERJA DAN IMPLEMENTASI

## 1. Instalasi Chocolatey Package Manager

Chocolatey merupakan package manager untuk Windows yang digunakan untuk mempermudah proses instalasi dan pengelolaan berbagai perangkat lunak melalui command line.

PowerShell dijalankan sebagai Administrator, kemudian perintah instalasi Chocolatey dijalankan:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString(
'https://community.chocolatey.org/install.ps1'))
```

Setelah proses instalasi selesai, Chocolatey dapat diperiksa menggunakan:

```powershell
choco --version
```

Jika berhasil, PowerShell akan menampilkan versi Chocolatey yang terpasang.

**Dokumentasi:**

![Instalasi Chocolatey](img/01-chocolatey.png)

---

## 2. Instalasi Dart SDK dan Flutter SDK

Setelah Chocolatey berhasil terpasang, Dart dan Flutter dapat dipasang melalui Chocolatey.

Perintah instalasi Dart:

```powershell
choco install dart-sdk -y
```

Kemudian Flutter:

```powershell
choco install flutter -y
```

Setelah proses instalasi selesai, versi Dart diperiksa menggunakan:

```powershell
dart --version
```

Flutter diperiksa menggunakan:

```powershell
flutter --version
```

Pada lingkungan praktikum ini Flutter yang digunakan adalah:

```text
Flutter 3.41.9
Dart 3.11.5
```

Flutter digunakan sebagai framework untuk membangun aplikasi multiplatform, sedangkan Dart merupakan bahasa pemrograman yang digunakan oleh Flutter.

**Dokumentasi:**

![Instalasi Dart dan Flutter](img/02-flutter-dart.png)

---

## 3. Instalasi Visual Studio Code dan Ekstensi Flutter

Visual Studio Code digunakan sebagai text editor/IDE untuk menulis dan mengelola kode aplikasi Flutter.

Setelah Visual Studio Code terpasang, beberapa ekstensi yang diperlukan adalah:

* Flutter
* Dart

Ekstensi Flutter menyediakan fitur seperti:

* *Syntax highlighting*
* *Code completion*
* *Debugging*
* *Hot reload*
* Integrasi Flutter SDK
* Integrasi perangkat Android

Setelah ekstensi terpasang, project Flutter dapat dibuka langsung melalui Visual Studio Code.

**Dokumentasi:**

![Visual Studio Code](img/03-vscode.png)

---

## 4. Instalasi Android Studio dan Android SDK

Android Studio digunakan untuk menyediakan ekosistem pengembangan Android yang dibutuhkan oleh Flutter.

Komponen yang diperlukan meliputi:

* Android SDK
* Android SDK Platform
* Android SDK Build-Tools
* Android SDK Platform-Tools
* Android SDK Command-line Tools
* Android Emulator
* CMake

Lokasi Android SDK yang digunakan pada sistem:

```text
C:\Users\arysf\AppData\Local\Android\Sdk
```

Konfigurasi Android dapat diperiksa menggunakan:

```powershell
flutter doctor -v
```

Hasil pemeriksaan menunjukkan Android SDK telah terdeteksi oleh Flutter.

**Dokumentasi:**

![Android Studio](img/04-android-studio.png)

---

## 5. Konfigurasi Android SDK dan Lisensi

Setelah Android SDK terpasang, lisensi Android perlu disetujui agar Flutter dapat melakukan proses build aplikasi Android.

Perintah yang digunakan:

```powershell
flutter doctor --android-licenses
```

Setiap lisensi yang ditampilkan dapat diterima dengan mengetik:

```text
y
```

Kemudian konfigurasi dapat diperiksa kembali:

```powershell
flutter doctor -v
```

Pada proses build aplikasi, Flutter juga dapat mengunduh komponen SDK yang belum tersedia secara otomatis.

Dalam praktikum ini, Flutter melakukan instalasi beberapa komponen, antara lain:

```text
Android SDK Build-Tools 35.0.0
Android SDK Platform 36
CMake 3.22.1
```

**Dokumentasi:**

![Android SDK dan License](img/05-android-sdk.png)

---

## 6. Konfigurasi Java dan Gradle

Flutter membutuhkan Java untuk melakukan proses build aplikasi Android.

Pada awal konfigurasi, Flutter menggunakan Java:

```text
OpenJDK 25.0.2
```

Namun konfigurasi tersebut menghasilkan masalah kompatibilitas dengan Gradle:

```text
Incompatible Java/Gradle versions.
Java Version: 25.0.2
Gradle Version: 8.14
```

Untuk mengatasi masalah tersebut, sistem menggunakan JDK 22 yang telah tersedia pada:

```text
C:\Program Files\Java\jdk-22
```

Flutter kemudian diarahkan agar menggunakan JDK tersebut:

```powershell
flutter config --jdk-dir="C:\Program Files\Java\jdk-22"
```

Konfigurasi diperiksa menggunakan:

```powershell
flutter doctor -v
```

Hasil pemeriksaan menunjukkan:

```text
Java binary at:
C:\Program Files\Java\jdk-22\bin\java
```

dan:

```text
Java version:
22.0.2
```

Setelah perubahan tersebut, proses build berhasil dilakukan.

**Dokumentasi:**

![Konfigurasi Java](img/06-java-gradle.png)

---

## 7. Konfigurasi Environment Variables

Environment Variables digunakan agar berbagai tools seperti Flutter, Dart, Java, dan Android SDK dapat diakses melalui command line.

Salah satu direktori penting Android SDK adalah:

```text
C:\Users\arysf\AppData\Local\Android\Sdk
```

Sedangkan direktori Platform-Tools yang berisi ADB adalah:

```text
C:\Users\arysf\AppData\Local\Android\Sdk\platform-tools
```

Direktori tersebut dapat ditambahkan ke `Path` Windows agar perintah:

```powershell
adb
```

dapat dijalankan langsung dari PowerShell.

Jika belum ditambahkan ke PATH, ADB dapat dijalankan menggunakan lokasi lengkap:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

**Dokumentasi:**

![Environment Variables](img/07-environment-variable.png)

---

## 8. Konfigurasi Git Safe Directory

Git dapat memberikan peringatan keamanan apabila repository berada pada direktori yang dianggap memiliki kepemilikan berbeda.

Untuk menandai repository sebagai direktori yang aman, digunakan:

```powershell
git config --global --add safe.directory "C:/Users/arysf/Documents/kuliah/Mobile/Git/244107020108-mobile-course"
```

Konfigurasi tersebut dapat diperiksa dengan:

```powershell
git config --global --get-all safe.directory
```

Konfigurasi `safe.directory` membantu Git mengenali repository sebagai direktori yang dipercaya.

**Dokumentasi:**

![Git Safe Directory](img/08-git-safe-directory.png)

---

## 9. Menghubungkan Perangkat Android dengan USB Debugging

Smartphone Android digunakan sebagai perangkat fisik untuk menjalankan aplikasi Flutter.

Langkah yang dilakukan:

1. Membuka **Settings** pada smartphone.
2. Membuka menu **About Phone**.
3. Mengaktifkan **Developer Options**.
4. Mengaktifkan **USB Debugging**.
5. Menghubungkan smartphone ke laptop menggunakan kabel USB.
6. Menyetujui permintaan otorisasi USB Debugging apabila muncul.

Perangkat kemudian diperiksa menggunakan Flutter:

```powershell
flutter devices
```

Perangkat Android yang terdeteksi:

```text
22101320G
Android 14
API 34
```

Perangkat tersebut memiliki identifier ADB:

```text
833cb99
```

**Dokumentasi:**

![USB Debugging](img/09-usb-debugging.png)

---

## 10. Membuat dan Menjalankan Project Flutter

Project Flutter dibuat dengan struktur dasar Flutter.

Contoh perintah pembuatan project:

```powershell
flutter create my_first_app
```

Kemudian masuk ke direktori project:

```powershell
cd my_first_app
```

Project dapat diperiksa menggunakan:

```powershell
flutter doctor
```

dan dijalankan dengan:

```powershell
flutter run
```

File utama aplikasi terdapat pada:

```text
lib/main.dart
```

Struktur dasar project Flutter terdiri dari beberapa bagian, seperti:

```text
my_first_app/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

**Dokumentasi:**

![Project Flutter](img/10-flutter-project.png)

---

## 11. Proses Build dan Debugging Aplikasi

Aplikasi dijalankan menggunakan:

```powershell
flutter run
```

Flutter kemudian menjalankan proses Gradle:

```text
Running Gradle task 'assembleDebug'...
```

Pada proses build, beberapa komponen Android SDK yang belum tersedia diunduh dan dipasang secara otomatis.

Setelah proses selesai, Flutter berhasil menghasilkan file APK:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

Output:

```text
√ Built
build\app\outputs\flutter-apk\app-debug.apk
```

Hal tersebut menunjukkan bahwa **proses build aplikasi berhasil**.

**Dokumentasi:**

![Flutter Build](img/11-flutter-build.png)

---

## 12. Instalasi APK dan Debugging pada Perangkat Fisik

Setelah APK berhasil dibuat, Flutter mencoba memasang APK ke smartphone Android.

Namun pada percobaan pertama, proses instalasi mengalami kendala:

```text
adb.exe: failed to install

Failure
[INSTALL_FAILED_USER_RESTRICTED:
Install canceled by user]
```

Error tersebut menunjukkan bahwa perangkat Android membatalkan atau membatasi proses instalasi aplikasi melalui ADB.

Pada tahap ini, masalah bukan lagi terdapat pada proses kompilasi Flutter karena APK telah berhasil dibuat.

Untuk pemeriksaan ADB secara manual, perintah yang digunakan adalah:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

Jika ADB telah masuk ke environment variable `Path`, perintah dapat disederhanakan menjadi:

```powershell
adb devices
```

Target output:

```text
List of devices attached
833cb99    device
```

Jika perangkat berstatus `unauthorized`, pengguna perlu menyetujui permintaan USB Debugging pada smartphone.

Untuk memasang APK secara manual:

```powershell
adb install -r ".\build\app\outputs\flutter-apk\app-debug.apk"
```

Apabila instalasi berhasil, output akan menunjukkan:

```text
Success
```

Setelah itu aplikasi dapat dijalankan kembali menggunakan:

```powershell
flutter run
```

**Dokumentasi:**

![ADB Debugging](img/12-adb-debugging.png)

---

# IV. RINGKASAN LANGKAH KERJA

Berikut merupakan ringkasan proses praktikum:

1. Menginstal Chocolatey pada Windows menggunakan PowerShell.
2. Menginstal Dart SDK dan Flutter SDK.
3. Menginstal Visual Studio Code.
4. Memasang ekstensi Flutter dan Dart pada Visual Studio Code.
5. Menginstal Android Studio dan Android SDK.
6. Menginstal Android SDK Build-Tools, Platform-Tools, Platform SDK, dan CMake.
7. Menyetujui Android SDK licenses.
8. Mengatur Java yang digunakan Flutter agar kompatibel dengan Gradle.
9. Mengatur Environment Variables dan konfigurasi Git `safe.directory`.
10. Mengaktifkan USB Debugging dan menghubungkan smartphone Android.
11. Membuat serta melakukan build project Flutter.
12. Melakukan debugging dan instalasi aplikasi pada perangkat fisik menggunakan ADB.

---

# V. IMPLEMENTASI KODE PROGRAM (`lib/main.dart`)

File utama aplikasi Flutter terdapat pada:

```text
lib/main.dart
```

Kode dasar aplikasi:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My First App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My First App'),
      ),
      body: const Center(
        child: Text(
          'Hello Flutter!',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
```

## Penjelasan Program

### `import`

```dart
import 'package:flutter/material.dart';
```

Digunakan untuk mengimpor library Material Design dari Flutter.

### Fungsi `main()`

```dart
void main() {
  runApp(const MyApp());
}
```

Fungsi `main()` merupakan titik awal eksekusi aplikasi Dart. Fungsi `runApp()` digunakan untuk menjalankan widget utama aplikasi.

### `MyApp`

```dart
class MyApp extends StatelessWidget
```

`MyApp` merupakan widget utama aplikasi. Widget ini menggunakan `StatelessWidget` karena tidak memiliki data yang berubah secara dinamis.

### `MaterialApp`

```dart
return MaterialApp(
```

`MaterialApp` menyediakan konfigurasi dasar aplikasi seperti tema, judul, dan halaman awal.

### `Scaffold`

```dart
return Scaffold(
```

`Scaffold` menyediakan struktur dasar halaman aplikasi, seperti `AppBar` dan `body`.

### `AppBar`

```dart
appBar: AppBar(
  title: const Text('My First App'),
),
```

Digunakan untuk menampilkan bar navigasi pada bagian atas aplikasi.

### `Center`

```dart
body: const Center(
```

Digunakan untuk menempatkan widget pada posisi tengah.

### `Text`

```dart
Text(
  'Hello Flutter!',
)
```

Digunakan untuk menampilkan teks pada aplikasi.

---

# VI. KESIMPULAN

Berdasarkan praktikum yang telah dilakukan, ekosistem pengembangan aplikasi Flutter pada sistem operasi Windows berhasil dikonfigurasi. Beberapa komponen yang digunakan meliputi Flutter SDK, Dart SDK, Visual Studio Code, Android Studio, Android SDK, Build-Tools, Platform-Tools, Git, serta perangkat Android fisik.

Pada proses konfigurasi ditemukan masalah kompatibilitas antara Java 25.0.2 dengan Gradle 8.14. Masalah tersebut berhasil ditangani dengan mengarahkan Flutter untuk menggunakan JDK 22 yang tersedia pada sistem:

```text
C:\Program Files\Java\jdk-22
```

Setelah konfigurasi Java diperbaiki, proses build Flutter berhasil menghasilkan APK debug:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

Dengan demikian, konfigurasi Flutter, Gradle, dan Android SDK telah dapat digunakan untuk melakukan proses kompilasi aplikasi.

Pada tahap instalasi APK ke perangkat fisik, ditemukan kendala:

```text
INSTALL_FAILED_USER_RESTRICTED:
Install canceled by user
```

Kendala tersebut berkaitan dengan pembatasan instalasi aplikasi melalui ADB pada perangkat Android, bukan dengan proses kompilasi aplikasi. Oleh karena itu, konfigurasi USB Debugging, otorisasi ADB, dan izin instalasi melalui USB perlu diperiksa kembali pada perangkat.

Secara keseluruhan, praktikum memberikan pemahaman mengenai hubungan antara Flutter SDK, Dart, Android SDK, Gradle, Java, ADB, Git, serta perangkat Android dalam proses pengembangan dan debugging aplikasi mobile.
