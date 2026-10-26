
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Beranda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Daftar pengumuman kampus terbaru.'),
          const SizedBox(height: 20),

          // Daftar announcement tetap ada di halaman Home.
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.campaign),
              ),
              title: const Text(
                'Jadwal kuliah berubah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Kelas Mobile pindah ke Ruang A2 '
                'jam 13.00.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push(
                  AppRoutes.announcementById('3'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
