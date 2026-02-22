import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../connection/providers/connection_provider.dart';
import '../../core/locale/locale_provider.dart';
import '../rpi/providers/rpi_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  // OctoPrint Controllers
  final _urlController = TextEditingController(text: 'http://192.168.1.156');
  final _apiController = TextEditingController(
    text: 'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0',
  );

  // RPi Controllers
  final _rpiHostController = TextEditingController();
  final _rpiTailscaleController = TextEditingController();
  final _rpiUserController = TextEditingController();
  final _rpiPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredRpiCredentials();
  }

  Future<void> _loadStoredRpiCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rpiHostController.text = prefs.getString('rpi_host') ?? '';
      _rpiTailscaleController.text = prefs.getString('rpi_tailscale_ip') ?? '';
      _rpiUserController.text = prefs.getString('rpi_username') ?? '';
      _rpiPassController.text = prefs.getString('rpi_password') ?? '';

      final savedUrl = prefs.getString('octo_url');
      final savedApi = prefs.getString('octo_api');
      if (savedUrl != null) _urlController.text = savedUrl;
      if (savedApi != null) _apiController.text = savedApi;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiController.dispose();
    _rpiHostController.dispose();
    _rpiTailscaleController.dispose();
    _rpiUserController.dispose();
    _rpiPassController.dispose();
    super.dispose();
  }

  Future<void> _connectOctoPrint() async {
    final url = _urlController.text.trim();
    final api = _apiController.text.trim();
    if (url.isEmpty || api.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('octo_url', url);
    await prefs.setString('octo_api', api);

    ref.read(connectionSettingsProvider.notifier).connect(url, api);
  }

  void _disconnectOctoPrint() {
    ref.read(connectionSettingsProvider.notifier).disconnect();
  }

  void _connectRpi() {
    ref
        .read(rpiProvider.notifier)
        .connect(
          _rpiHostController.text.trim(),
          _rpiTailscaleController.text.trim(),
          _rpiUserController.text.trim(),
          _rpiPassController.text,
        );
  }

  void _disconnectRpi() {
    ref.read(rpiProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final octoSettings = ref.watch(connectionSettingsProvider);
    final rpiState = ref.watch(rpiProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // --- OctoPrint Section ---
            Text(
              l10n.connectToOctoprint,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (octoSettings == null)
              _buildOctoPrintForm(l10n)
            else
              _buildOctoPrintConnectedCard(l10n, octoSettings, theme),

            const SizedBox(height: 48),

            // --- RPi Section ---
            Text(
              l10n.rpiConnectionInfo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (rpiState.client == null)
              _buildRpiForm(l10n, rpiState, theme)
            else
              _buildRpiConnectedCard(l10n, rpiState, theme),

            const SizedBox(height: 48),

            // --- Language Section ---
            _buildLanguageToggle(locale),
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

  Widget _buildOctoPrintForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _connectOctoPrint,
          icon: const Icon(Icons.login),
          label: Text(l10n.connect),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildOctoPrintConnectedCard(
    AppLocalizations l10n,
    ConnectionSettings settings,
    ThemeData theme,
  ) {
    final maskedApiKey = settings.apiKey.length > 4
        ? '••••••••••••••••${settings.apiKey.substring(settings.apiKey.length - 4)}'
        : '••••';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow(l10n.serverUrl, settings.baseUrl, theme),
            const Divider(height: 32),
            _buildInfoRow(l10n.apiKey, maskedApiKey, theme),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _disconnectOctoPrint,
              icon: const Icon(Icons.logout),
              label: Text(l10n.disconnect),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRpiForm(AppLocalizations l10n, RpiState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _rpiHostController,
          decoration: InputDecoration(
            labelText: l10n.rpiHost,
            prefixIcon: const Icon(Icons.dns),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _rpiTailscaleController,
          decoration: InputDecoration(
            labelText: l10n.rpiTailscaleIP,
            prefixIcon: const Icon(Icons.cloud_sync),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _rpiUserController,
          decoration: InputDecoration(
            labelText: l10n.username,
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _rpiPassController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: const Icon(Icons.password),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        if (state.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              state.error,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        FilledButton.icon(
          onPressed: state.isConnecting ? null : _connectRpi,
          icon: state.isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.terminal),
          label: Text(l10n.connectSsh),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildRpiConnectedCard(
    AppLocalizations l10n,
    RpiState state,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow(l10n.rpiConnectionInfo, 'Bağlı (Connected)', theme),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _disconnectRpi,
              icon: const Icon(Icons.link_off),
              label: Text(l10n.disconnect),
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
