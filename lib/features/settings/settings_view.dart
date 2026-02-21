import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/providers/connection_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(connectionSettingsProvider);
    final theme = Theme.of(context);

    if (settings == null) {
      return const Center(child: Text('Bağlantı Yok'));
    }

    // Mask API key for security (show only last 4 chars)
    final maskedApiKey = settings.apiKey.length > 4
        ? '••••••••••••••••${settings.apiKey.substring(settings.apiKey.length - 4)}'
        : '••••';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Bağlantı Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Bağlantı Adresi (URL)',
                      settings.baseUrl,
                      theme,
                    ),
                    const Divider(height: 32),
                    _buildInfoRow('WebSocket Adresi', settings.wsUrl, theme),
                    const Divider(height: 32),
                    _buildInfoRow('API Anahtarı', maskedApiKey, theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Disconnecting by setting the provider to null
                  ref.read(connectionSettingsProvider.notifier).state = null;
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Bağlantıyı Kes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'OctoMobile v1.0.0\nFlutter ile Geliştirildi',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
