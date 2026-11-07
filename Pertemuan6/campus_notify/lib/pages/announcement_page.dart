
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<AnnouncementPage> createState() =>
      _AnnouncementPageState();
}

class _AnnouncementPageState
    extends ConsumerState<AnnouncementPage> {
  bool _markingRead = false;

  Future<void> _markAsReadAfterBack() async {
    if (_markingRead) return;

    _markingRead = true;

    try {
      await ref
          .read(notificationRepositoryProvider)
          .markAsRead(widget.id);
    } catch (e) {
      debugPrint('Gagal menandai notifikasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState =
        ref.watch(notificationDetailProvider(widget.id));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _markAsReadAfterBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Notifikasi'),
        ),
        body: notificationState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Gagal mengambil detail notifikasi: $error',
              ),
            ),
          ),
          data: (item) {
            if (item == null) {
              return const Center(
                child: Text('Notifikasi tidak ditemukan.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.createdAt!.toLocal().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
