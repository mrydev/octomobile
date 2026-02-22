import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';
import '../../../core/utils/notification_service.dart';

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
  int _lastNotifiedProgress = 0;
  bool _wasPrinting = false;

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

            if (newStatus != null) {
              final isPrinting = newStatus.toLowerCase().contains('printing');

              if (isPrinting && !_wasPrinting) {
                // Print started
                NotificationService().showNotification(
                  id: 1,
                  title: 'Baskı Başladı',
                  body: newFileName ?? 'Yeni bir baskı işlemi başladı.',
                );
                _lastNotifiedProgress = 0;
              } else if (!isPrinting && _wasPrinting) {
                // Print finished or stopped
                if (newStatus.toLowerCase().contains('operational')) {
                  NotificationService().showNotification(
                    id: 2,
                    title: 'Baskı Tamamlandı',
                    body: 'Baskı işleminiz başarıyla bitti.',
                  );
                } else if (!newStatus.toLowerCase().contains('offline')) {
                  NotificationService().showNotification(
                    id: 3,
                    title: 'Baskı Durdu',
                    body: 'Durum: $newStatus',
                  );
                }
              }
              _wasPrinting = isPrinting;
            }

            if (newProgress != null && _wasPrinting) {
              int currentDecade = (newProgress / 10).floor() * 10;
              if (currentDecade > _lastNotifiedProgress &&
                  currentDecade > 0 &&
                  currentDecade < 100) {
                NotificationService().showNotification(
                  id: 4,
                  title: 'Baskı İlerlemesi',
                  body: 'Baskı %$currentDecade tamamlandı.',
                );
                _lastNotifiedProgress = currentDecade;
              }
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
