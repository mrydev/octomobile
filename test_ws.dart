import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final wsUrl = 'ws://192.168.1.156/sockjs/websocket';
  final apiKey = 'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0';

  print('Connecting to $wsUrl');
  final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

  channel.sink.add(json.encode({"auth": "user:$apiKey"}));

  int count = 0;
  channel.stream.listen(
    (data) {
      print('RAW DATA RECIEVED:');
      print(data);
      print('---');

      count++;
      if (count > 3) {
        channel.sink.close();
        print('Done.');
      }
    },
    onError: (e) {
      print('Error: $e');
    },
  );
}
