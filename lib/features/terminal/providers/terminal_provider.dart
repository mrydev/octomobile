import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';

class TerminalNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    ref.listen(webSocketMessageProvider, (previous, next) {
      if (next is AsyncData) {
        final data = next.value!;
        if (data.containsKey('current') || data.containsKey('history')) {
          final payload = data['current'] ?? data['history'];
          if (payload != null && payload['logs'] != null) {
            final newLogs = (payload['logs'] as List).cast<String>();
            if (newLogs.isNotEmpty) {
              final combined = [...state, ...newLogs];
              // Keep maximum of 300 lines to prevent memory issues
              if (combined.length > 300) {
                state = combined.sublist(combined.length - 300);
              } else {
                state = combined;
              }
            }
          }
        }
      }
    });

    return [];
  }

  void clearLogs() {
    state = [];
  }
}

final terminalProvider = NotifierProvider<TerminalNotifier, List<String>>(() {
  return TerminalNotifier();
});
