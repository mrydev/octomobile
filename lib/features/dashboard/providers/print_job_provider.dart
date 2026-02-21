import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';

class PrintJobState {
  final double progress;
  final String status;
  final String fileName;
  final int printTimeLeft;
  final int printTime;

  const PrintJobState({
    this.progress = 0.0,
    this.status = "Offline",
    this.fileName = "No file selected",
    this.printTimeLeft = 0,
    this.printTime = 0,
  });

  PrintJobState copyWith({
    double? progress,
    String? status,
    String? fileName,
    int? printTimeLeft,
    int? printTime,
  }) {
    return PrintJobState(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      printTimeLeft: printTimeLeft ?? this.printTimeLeft,
      printTime: printTime ?? this.printTime,
    );
  }
}

class PrintJobNotifier extends Notifier<PrintJobState> {
  @override
  PrintJobState build() {
    ref.listen(webSocketMessageProvider, (previous, next) {
      if (next is AsyncData) {
        final data = next.value!;
        if (data.containsKey('current') || data.containsKey('history')) {
          final payload = data['current'] ?? data['history'];

          if (payload != null) {
            String? newStatus;
            String? newFileName;
            double? newProgress;
            int? newTimeLeft;
            int? newTime;

            if (payload['state'] != null) {
              newStatus = payload['state']['text'];
            }
            if (payload['job'] != null && payload['job']['file'] != null) {
              newFileName = payload['job']['file']['name'];
            }
            if (payload['progress'] != null) {
              final completion = payload['progress']['completion'];
              newProgress = completion != null
                  ? (completion as num).toDouble()
                  : null;
              newTimeLeft = payload['progress']['printTimeLeft'] as int?;
              newTime = payload['progress']['printTime'] as int?;
            }

            state = state.copyWith(
              status: newStatus,
              fileName: newFileName,
              progress: newProgress,
              printTimeLeft: newTimeLeft,
              printTime: newTime,
            );
          }
        }
      }
    });

    return const PrintJobState();
  }
}

final printJobProvider = NotifierProvider<PrintJobNotifier, PrintJobState>(() {
  return PrintJobNotifier();
});
