
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari aplikasi?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ref.read(authStateProvider.notifier).logout();
      // Route guard di main.dart akan mengarahkan ke /login.
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logout gagal. Silakan coba kembali.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
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
          const Text(
            'Daftar pengumuman kampus terbaru.',
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.campaign),
              ),
              title: const Text(
                'Jadwal kuliah berubah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
