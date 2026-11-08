import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_provider.dart';
import '../domain/campus_notification.dart';

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
  late Future<CampusNotification?> _detail;
  bool _receiptScheduled = false;

  @override
  void initState() {
    super.initState();
    _detail = _loadDetail();
  }

  @override
  void didUpdateWidget(covariant AnnouncementPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id ||
        oldWidget.initialNotification != widget.initialNotification) {
      _receiptScheduled = false;
      _detail = _loadDetail();
    }
  }

  Future<CampusNotification?> _loadDetail() async {
    // A list item already contains the complete local message. Do not resolve
    // it again using a potentially outdated announcement route.
    final initial = widget.initialNotification;
    if (initial != null) return initial;
    // Notification tray/cold starts have no extra and still use persistence.
    return ref.read(notificationRepositoryProvider).getNotification(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CampusNotification?>(
      future: _detail,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Notifikasi')),
          body: Builder(
            builder: (context) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat detail notifikasi.'),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = snapshot.data;
              if (item == null) {
                return const Center(child: Text('Notifikasi tidak ditemukan.'));
              }
              if (!_receiptScheduled) {
                _receiptScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!mounted) return;
                  try {
                    await ref
                        .read(notificationRepositoryProvider)
                        .deleteNotification(item.id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Status baca belum tersimpan. Buka kembali untuk mencoba lagi.',
                          ),
                        ),
                      );
                    }
                  }
                });
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    item.body,
                    style: const TextStyle(fontSize: 16, height: 1.5),
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
        );
      },
    );
  }
}
