import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.files),
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
            return Center(child: Text(l10n.noFilesFound));
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
                          final messenger = ScaffoldMessenger.of(context);
                          if (apiClient != null) {
                            apiClient
                                .printFile(name)
                                .then((_) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$name ${l10n.printStarted}',
                                      ),
                                    ),
                                  );
                                })
                                .catchError((err) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${l10n.commandFailed}: $err',
                                      ),
                                    ),
                                  );
                                });
                          }
                        },
                      ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('${l10n.fetchError}:\n$err', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
