
import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        // Tombol Back otomatis muncul jika ada halaman sebelumnya.
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.campaign,
            size: 72,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Pengumuman $id',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jadwal kuliah berubah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelas Mobile pindah ke Ruang A2 '
            'jam 13.00.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Home'),
          ),
        ],
      ),
    );
  }
}
