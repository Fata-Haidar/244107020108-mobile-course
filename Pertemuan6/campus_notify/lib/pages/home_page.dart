
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/notification_repository.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  bool _tokenRegistrationStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_tokenRegistrationStarted) {
      _tokenRegistrationStarted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _registerFcmToken();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
    }
  }

  void _refreshNotifications() {
    if (!mounted) return;
    ref.invalidate(notificationsProvider);
  }

  Future<void> _registerFcmToken() async {
    try {
      await initFcmToken(
        onToken: (token) {
          return ref
              .read(notificationRepositoryProvider)
              .saveDeviceToken(token);
        },
      );
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> _openNotification(
    CampusNotification item,
  ) async {
    await context.push(
      AppRoutes.announcementById(item.id),
    );

    if (!mounted) return;

    // Refresh setelah kembali dari halaman detail.
    // Semua notifikasi tetap ditampilkan.
    _refreshNotifications();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari aplikasi?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(authStateProvider.notifier).logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: $e')),
      );
    }
  }

  void _showNotificationsInfo(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count notifikasi belum dibaca'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          notificationState.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => IconButton(
              onPressed: _refreshNotifications,
              icon: const Icon(Icons.refresh),
            ),
            data: (items) {
              final unreadCount =
                  items.where((item) => !item.isRead).length;

              return IconButton(
                tooltip: 'Notifikasi ($unreadCount belum dibaca)',
                onPressed: () {
                  _showNotificationsInfo(unreadCount);
                },
                icon: _NotificationBell(
                  count: unreadCount,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          _refreshNotifications();

          await Future<void>.delayed(
            const Duration(milliseconds: 500),
          );
        },

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          children: [
            const Text(
              'Notifikasi Kampus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            notificationState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),

              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Gagal memuat notifikasi: $error',
                  ),
                ),
              ),

              data: (items) {
                // Tampilkan SEMUA notifikasi.
                // Jangan filter hanya notifikasi belum dibaca.
                final unreadCount = items
                    .where((item) => !item.isRead)
                    .length;

                if (items.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text('Belum ada notifikasi.'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${items.length} total notifikasi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$unreadCount belum dibaca',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...items.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),

                        color: item.isRead
                            ? Colors.grey.withAlpha(15)
                            : Colors.blue.withAlpha(15),

                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isRead
                                ? Colors.grey.shade300
                                : Colors.blue.shade100,

                            child: Icon(
                              item.isRead
                                  ? Icons.notifications_none
                                  : Icons.campaign_outlined,

                              color: item.isRead
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                          ),

                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),

                              Text(
                                item.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                item.isRead
                                    ? 'Sudah dibaca'
                                    : 'Belum dibaca',

                                style: TextStyle(
                                  fontSize: 12,
                                  color: item.isRead
                                      ? Colors.grey
                                      : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              if (item.createdAt != null) ...[
                                const SizedBox(height: 5),

                                Text(
                                  item.createdAt!
                                      .toLocal()
                                      .toString(),

                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ],
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,
                          ),

                          onTap: () {
                            _openNotification(item);
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),

        if (count > 0)
          Positioned(
            right: -8,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),

              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),

              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),

              alignment: Alignment.center,

              child: Text(
                count > 99 ? '99+' : '$count',

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
