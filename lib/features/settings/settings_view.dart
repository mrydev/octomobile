import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/providers/connection_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _urlController = TextEditingController(text: 'http://192.168.1.156');
  final _apiController = TextEditingController(
    text: 'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0',
  );

  @override
  void dispose() {
    _urlController.dispose();
    _apiController.dispose();
    super.dispose();
  }

  void _connect() {
    final url = _urlController.text.trim();
    final api = _apiController.text.trim();
    if (url.isEmpty || api.isEmpty) return;

    final wsUrl = url.replaceFirst('http', 'ws') + '/sockjs/websocket';

    ref.read(connectionSettingsProvider.notifier).state = ConnectionSettings(
      baseUrl: url,
      apiKey: api,
      wsUrl: wsUrl,
    );
  }

  void _disconnect() {
    ref.read(connectionSettingsProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(connectionSettingsProvider);
    final theme = Theme.of(context);

    if (settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bağlantı Ayarları'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.print_disabled, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'OctoPrint\'e Bağlan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Sunucu Adresi (URL)',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Anahtarı',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _connect,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Bağlan', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
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
                onPressed: _disconnect,
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
