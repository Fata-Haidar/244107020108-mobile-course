import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/sync.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/note_tile.dart';
import 'posts_page.dart';
import 'setting_page.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<NoteFormResult>(
      context: context,
      builder: (_) => const NoteFormDialog(),
    );

    if (result == null) return;

    await ref.read(noteActionsProvider).add(
          result.title,
          result.body,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          Tooltip(
            message: 'Catatan belum tersinkron',
            child: Badge(
              isLabelVisible: dirty > 0,
              label: Text('$dirty'),
              child: const Icon(
                Icons.cloud_upload_outlined,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Posts (cache-first)',
            icon: const Icon(
              Icons.article_outlined,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PostsPage(),
                ),
              );
            },
          ),

          IconButton(
            tooltip: 'Sinkronkan',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final messenger =
                  ScaffoldMessenger.of(context);

              try {
                final count = await ref
                    .read(noteActionsProvider)
                    .sync();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      count == 0
                          ? 'Semua catatan sudah tersinkron'
                          : '$count catatan berhasil disinkronkan',
                    ),
                  ),
                );
              } on OfflineException catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                  ),
                );
              }
            },
          ),

          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(
              Icons.settings_outlined,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: notesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => _ErrorView(
          message: 'Gagal membaca database: $e',
          onRetry: () {
            ref.invalidate(notesProvider);
          },
        ),

        data: (notes) {
          if (notes.isEmpty) {
            return const _EmptyView();
          }

          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];

              return NoteTile(
                note: note,

                // KLIK CATATAN -> HALAMAN DETAIL
                onTap: () {
                  if (note.id == null) return;

                  context.push(
                    '/note/${note.id}',
                  );
                },

                onDelete: () {
                  if (note.id == null) return;

                  ref
                      .read(noteActionsProvider)
                      .delete(note.id!);
                },
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        // Tombol + tetap untuk tambah catatan
        onPressed: () {
          _openForm(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada catatan. Tekan + untuk menambah.',
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}