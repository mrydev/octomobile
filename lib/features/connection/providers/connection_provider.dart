import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/octoprint_api_client.dart';
import '../../../core/api/websocket_service.dart';

class ConnectionSettings {
  final String baseUrl;
  final String apiKey;
  final String wsUrl;

  ConnectionSettings({
    required this.baseUrl,
    required this.apiKey,
    required this.wsUrl,
  });
}

class ConnectionSettingsNotifier extends StateNotifier<ConnectionSettings?> {
  ConnectionSettingsNotifier() : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final apiKey = prefs.getString('apiKey');
    final wsUrl = prefs.getString('wsUrl');

    if (baseUrl != null && apiKey != null && wsUrl != null) {
      state = ConnectionSettings(
        baseUrl: baseUrl,
        apiKey: apiKey,
        wsUrl: wsUrl,
      );
    }
  }

  Future<void> connect(String baseUrl, String apiKey, String wsUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', baseUrl);
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('wsUrl', wsUrl);

    state = ConnectionSettings(baseUrl: baseUrl, apiKey: apiKey, wsUrl: wsUrl);
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('baseUrl');
    await prefs.remove('apiKey');
    await prefs.remove('wsUrl');

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
