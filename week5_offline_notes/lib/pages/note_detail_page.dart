import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final noteAsync =
        ref.watch(noteByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
      ),
      body: noteAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat catatan: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),

        data: (note) {
          if (note == null) {
            return const Center(
              child: Text(
                'Catatan tidak ditemukan',
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  note.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 16),

                Text(
                  note.body.isEmpty
                      ? '(tanpa isi)'
                      : note.body,
                ),

                const SizedBox(height: 24),

                Text(
                  'Terakhir diperbarui',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge,
                ),

                const SizedBox(height: 4),

                Text(
                  note.updatedAt.toString(),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Icon(
                      note.dirty
                          ? Icons.cloud_off
                          : Icons.cloud_done,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      note.dirty
                          ? 'Belum tersinkron'
                          : 'Sudah tersinkron',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Ubah Catatan',
                  ),
                  onPressed: () async {
                    final result =
                        await showDialog<NoteFormResult>(
                      context: context,
                      builder: (_) =>
                          NoteFormDialog(
                        initial: note,
                      ),
                    );

                    if (result == null) {
                      return;
                    }

                    await ref
                        .read(noteActionsProvider)
                        .update(
                          note.copyWith(
                            title: result.title,
                            body: result.body,
                          ),
                        );

                    ref.invalidate(
                      noteByIdProvider(id),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Catatan berhasil diperbarui',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}