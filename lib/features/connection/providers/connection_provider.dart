import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/octoprint_api_client.dart';
import '../../../core/api/websocket_service.dart';

class ConnectionSettings {
  final String activeUrl; // The currently active/reachable URL
  final String apiKey;
  final String wsUrl; // Derived from activeUrl
  final String configuredUrl; // The one the user actually typed in Settings

  ConnectionSettings({
    required this.activeUrl,
    required this.apiKey,
    required this.wsUrl,
    required this.configuredUrl,
  });

  // Backward compatibility getters
  String get baseUrl => activeUrl;
}

class ConnectionSettingsNotifier extends StateNotifier<ConnectionSettings?> {
  ConnectionSettingsNotifier() : super(null) {
    _loadSettings();
  }

  Future<String?> _testAndDetermineActiveUrl(
    String configUrl,
    String apiKey,
  ) async {
    // 1. Ensure configUrl has scheme
    String safeConfigUrl = configUrl;
    if (!safeConfigUrl.startsWith('http://') &&
        !safeConfigUrl.startsWith('https://')) {
      safeConfigUrl = 'http://$safeConfigUrl';
    }

    // 2. Test primary configured URL
    try {
      final res = await http
          .get(
            Uri.parse('$safeConfigUrl/api/version'),
            headers: {'X-Api-Key': apiKey},
          )
          .timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) return safeConfigUrl;
    } catch (_) {}

    // 3. Test Tailscale fallback URL
    final prefs = await SharedPreferences.getInstance();
    String tailscaleIp = prefs.getString('rpi_tailscale_ip') ?? '';

    if (tailscaleIp.isNotEmpty) {
      // Strip any accidental spaces or schemes from tailscale IP
      tailscaleIp = tailscaleIp
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .trim();

      try {
        final uri = Uri.parse(safeConfigUrl);
        final fallbackUri = uri.replace(host: tailscaleIp);
        final fallbackUrl = fallbackUri.toString();

        final res = await http
            .get(
              Uri.parse('$fallbackUrl/api/version'),
              headers: {'X-Api-Key': apiKey},
            )
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) return fallbackUrl;
      } catch (_) {}
    }

    return null; // Return null if neither worked
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final configuredUrl = prefs.getString('baseUrl');
    final apiKey = prefs.getString('apiKey');

    if (configuredUrl != null && apiKey != null && configuredUrl.isNotEmpty) {
      String safeConfigUrl = configuredUrl;
      if (!safeConfigUrl.startsWith('http://') &&
          !safeConfigUrl.startsWith('https://')) {
        safeConfigUrl = 'http://$safeConfigUrl';
      }

      // 1. Immediately set the state using the configured URL so UI starts normally
      final primaryWsUrl =
          safeConfigUrl
              .replaceFirst('http', 'ws')
              .replaceFirst('https', 'wss') +
          '/sockjs/websocket';

      state = ConnectionSettings(
        activeUrl: safeConfigUrl,
        apiKey: apiKey,
        wsUrl: primaryWsUrl,
        configuredUrl: safeConfigUrl,
      );

      // 2. Check in background if we need to switch to Tailscale
      final activeUrl = await _testAndDetermineActiveUrl(safeConfigUrl, apiKey);
      if (activeUrl != null && activeUrl != safeConfigUrl && mounted) {
        final activeWsUrl =
            activeUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss') +
            '/sockjs/websocket';

        state = ConnectionSettings(
          activeUrl: activeUrl,
          apiKey: apiKey,
          wsUrl: activeWsUrl,
          configuredUrl: safeConfigUrl,
        );
      }
    }
  }

  Future<void> connect(String configuredUrl, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();

    String safeConfigUrl = configuredUrl;
    if (!safeConfigUrl.startsWith('http://') &&
        !safeConfigUrl.startsWith('https://')) {
      safeConfigUrl = 'http://$safeConfigUrl';
    }

    await prefs.setString('baseUrl', safeConfigUrl);
    await prefs.setString('apiKey', apiKey);

    // Set immediate state
    final primaryWsUrl =
        safeConfigUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss') +
        '/sockjs/websocket';

    state = ConnectionSettings(
      activeUrl: safeConfigUrl,
      apiKey: apiKey,
      wsUrl: primaryWsUrl,
      configuredUrl: safeConfigUrl,
    );

    // Test in background for fallback
    final activeUrl = await _testAndDetermineActiveUrl(safeConfigUrl, apiKey);
    if (activeUrl != null && activeUrl != safeConfigUrl && mounted) {
      final activeWsUrl =
          activeUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss') +
          '/sockjs/websocket';

      state = ConnectionSettings(
        activeUrl: activeUrl,
        apiKey: apiKey,
        wsUrl: activeWsUrl,
        configuredUrl: safeConfigUrl,
      );
    }
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('baseUrl');
    await prefs.remove('apiKey');
    state = null;
  }
}

// Holds the currently active connection settings and handles persistence.
final connectionSettingsProvider =
    StateNotifierProvider<ConnectionSettingsNotifier, ConnectionSettings?>(
      (ref) => ConnectionSettingsNotifier(),
    );

// Provides the REST API client configured with the current connection settings.
final apiClientProvider = Provider<OctoPrintApiClient?>((ref) {
  final settings = ref.watch(connectionSettingsProvider);
  if (settings == null) return null;

  return OctoPrintApiClient(baseUrl: settings.baseUrl, apiKey: settings.apiKey);
});

// Provides the WebSocket service, automatically connecting and disconnecting based on provider lifecycle.
final webSocketServiceProvider = Provider<WebSocketService?>((ref) {
  final settings = ref.watch(connectionSettingsProvider);
  if (settings == null) return null;

  final service = WebSocketService(
    wsUrl: settings.wsUrl,
    baseUrl: settings.baseUrl,
    apiKey: settings.apiKey,
  );
  service.connect();

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
});

// A stream provider to cleanly access WebSocket payloads directly in UI widgets.
final webSocketMessageProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  if (wsService == null) return const Stream.empty();
  return wsService.messageStream;
});
