import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../connection/providers/connection_provider.dart';
import '../../core/locale/locale_provider.dart';

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

    ref.read(connectionSettingsProvider.notifier).connect(url, api, wsUrl);
  }

  void _disconnect() {
    ref.read(connectionSettingsProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(connectionSettingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    if (settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.noConnection),
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
                Text(
                  l10n.connectToOctoprint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: l10n.serverUrl,
                    prefixIcon: const Icon(Icons.link),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.apiKey,
                    prefixIcon: const Icon(Icons.key),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _connect,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    l10n.connect,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                _buildLanguageToggle(locale),
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
        title: Text(l10n.settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              l10n.connectionInfo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(l10n.serverUrl, settings.baseUrl, theme),
                    const Divider(height: 32),
                    _buildInfoRow(l10n.wsAddress, settings.wsUrl, theme),
                    const Divider(height: 32),
                    _buildInfoRow(l10n.apiKey, maskedApiKey, theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildLanguageToggle(locale),
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
                label: Text(
                  l10n.disconnect,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'OctoMobile v1.0.0\n${l10n.developedWithFlutter}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(Locale currentLocale) {
    return Center(
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'en', label: Text('English')),
          ButtonSegment(value: 'tr', label: Text('Türkçe')),
        ],
        selected: {currentLocale.languageCode},
        onSelectionChanged: (Set<String> newSelection) {
          ref
              .read(localeProvider.notifier)
              .setLocale(Locale(newSelection.first));
        },
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
