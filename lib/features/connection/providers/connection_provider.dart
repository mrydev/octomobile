import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Holds the currently active connection settings. When null, there's no active connection.
final connectionSettingsProvider = StateProvider<ConnectionSettings?>(
  (ref) => null,
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
