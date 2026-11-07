import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/campus_notification.dart';
import '../providers/notification_provider.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({
    super.key,
    required this.id,
    this.initialNotification,
  });

  final String id;
  final CampusNotification? initialNotification;

  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.initialNotification != null) {
      return _buildScaffold(context, widget.initialNotification!);
    }

    final notificationState = ref.watch(notificationDetailProvider(widget.id));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Notifikasi')),
        body: notificationState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Gagal mengambil detail notifikasi: $error'),
            ),
          ),
          data: (item) {
            if (item == null) {
              return const Center(child: Text('Notifikasi tidak ditemukan.'));
            }

            return _notificationContent(context, item);
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, CampusNotification notification) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Notifikasi')),
        body: _notificationContent(context, notification),
      ),
    );
  }

  Widget _notificationContent(BuildContext context, CampusNotification item) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.campaign_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: 20),
        Text(
          item.title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        if (item.createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            item.createdAt!.toLocal().toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 20),
        Text(item.body, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali'),
        ),
      ],
    );
  }
}
