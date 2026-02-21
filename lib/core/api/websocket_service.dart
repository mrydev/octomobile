import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class WebSocketService {
  final String wsUrl;
  final String baseUrl;
  final String apiKey;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  WebSocketService({
    required this.wsUrl,
    required this.baseUrl,
    required this.apiKey,
  });

  Future<void> connect() async {
    try {
      // 1. Passive Login to get session Key
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({"passive": true}),
      );

      String? sessionKey;
      String? userName;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        sessionKey = data['session'];
        userName = data['name'];
      }

      // 2. Connect to WebSocket
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);

      // 3. Authenticate with Session Key (Not API Key)
      if (sessionKey != null && userName != null) {
        _channel?.sink.add(json.encode({"auth": "$userName:$sessionKey"}));
      }

      _subscription = _channel?.stream.listen(
        (data) {
          try {
            final decoded = json.decode(data);
            _messageController.add(decoded);
          } catch (e) {
            debugPrint("WebSocket JSON Parse Error: $e");
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _reconnect();
        },
        onDone: () {
          debugPrint("WebSocket connection closed");
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    // Basic reconnect logic
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
  }
}
