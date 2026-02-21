import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/providers/connection_provider.dart';

// Simple provider to fetch and cache files
final filesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  if (apiClient == null) return [];
  return await apiClient.getFiles();
});

class FilesView extends ConsumerWidget {
  const FilesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(filesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files (G-Code)'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(filesProvider),
          ),
        ],
      ),
      body: filesAsync.when(
        data: (files) {
          if (files.isEmpty) {
            return const Center(child: Text('Yüklü dosya bulunamadı.'));
          }
          // Filter only machine code files (optional) or just display folders & files
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final isFolder = file['type'] == 'folder';
              final name = file['display'] ?? file['name'] ?? 'Unknown';
              final size = file['size'] ?? 0;

              String sizeStr = '';
              if (!isFolder && size > 0) {
                sizeStr = '${(size / 1024 / 1024).toStringAsFixed(2)} MB';
              }

              return ListTile(
                leading: Icon(
                  isFolder ? Icons.folder : Icons.insert_drive_file,
                  color: isFolder
                      ? Colors.amber
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(name),
                subtitle: isFolder ? null : Text(sizeStr),
                trailing: isFolder
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () {
                          final apiClient = ref.read(apiClientProvider);
                          apiClient
                              ?.printFile(name)
                              .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$name yazdırma başlatıldı.'),
                                  ),
                                );
                              })
                              .catchError((err) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Hata: $err')),
                                );
                              });
                        },
                      ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Dosyalar alınamadı:\n$err', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
