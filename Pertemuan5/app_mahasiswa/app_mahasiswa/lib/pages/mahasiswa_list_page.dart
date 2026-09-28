import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mahasiswa_provider.dart';
import 'form_page.dart';

class MahasiswaListPage extends ConsumerWidget {
  const MahasiswaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mahasiswaAsync = ref.watch(mahasiswaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
      ),

      body: mahasiswaAsync.when(
        // LOADING
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // ERROR
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(mahasiswaProvider);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),

        // DATA
        data: (mahasiswa) {
          if (mahasiswa.isEmpty) {
            return const Center(
              child: Text('Belum ada data mahasiswa'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(mahasiswaProvider.notifier)
                  .refreshData();
            },
            child: ListView.builder(
              itemCount: mahasiswa.length,
              itemBuilder: (context, index) {
                final mhs = mahasiswa[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      mhs.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIM: ${mhs.nim}'),
                        Text('Prodi: ${mhs.prodi}'),
                        Text('Email: ${mhs.email}'),
                      ],
                    ),

                    // EDIT & DELETE
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormPage(
                                  mahasiswa: mhs,
                                ),
                              ),
                            );

                            if (result == true) {
                              ref.invalidate(
                                mahasiswaProvider,
                              );
                            }
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            if (mhs.id != null) {
                              await ref
                                  .read(
                                    mahasiswaProvider
                                        .notifier,
                                  )
                                  .hapus(mhs.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // TOMBOL +
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FormPage(),
            ),
          );

          // setelah tambah data, refresh list
          if (result == true) {
            ref.invalidate(mahasiswaProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}