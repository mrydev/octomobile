import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';

class TemperatureState {
  final double toolCurrent;
  final double toolTarget;
  final double bedCurrent;
  final double bedTarget;

  const TemperatureState({
    this.toolCurrent = 0.0,
    this.toolTarget = 0.0,
    this.bedCurrent = 0.0,
    this.bedTarget = 0.0,
  });

  TemperatureState copyWith({
    double? toolCurrent,
    double? toolTarget,
    double? bedCurrent,
    double? bedTarget,
  }) {
    return TemperatureState(
      toolCurrent: toolCurrent ?? this.toolCurrent,
      toolTarget: toolTarget ?? this.toolTarget,
      bedCurrent: bedCurrent ?? this.bedCurrent,
      bedTarget: bedTarget ?? this.bedTarget,
    );
  }
}

class TemperatureNotifier extends Notifier<TemperatureState> {
  @override
  TemperatureState build() {
    // Listen to the WebSocket stream to accumulate temperature data
    ref.listen(webSocketMessageProvider, (previous, next) {
      if (next is AsyncData) {
        final data = next.value!;
        if (data.containsKey('current') || data.containsKey('history')) {
          final payload = data['current'] ?? data['history'];
          if (payload != null &&
              payload['temps'] != null &&
              (payload['temps'] as List).isNotEmpty) {
            // OctoPrint 'temps' is a list of time-series data
            final latestTemps = payload['temps'].last;

            double? newToolCurr;
            double? newToolTarg;
            double? newBedCurr;
            double? newBedTarg;

            if (latestTemps['tool0'] != null) {
              newToolCurr = _parseDouble(latestTemps['tool0']['actual']);
              newToolTarg = _parseDouble(latestTemps['tool0']['target']);
            }
            if (latestTemps['bed'] != null) {
              newBedCurr = _parseDouble(latestTemps['bed']['actual']);
              newBedTarg = _parseDouble(latestTemps['bed']['target']);
            }

            state = state.copyWith(
              toolCurrent: newToolCurr,
              toolTarget: newToolTarg,
              bedCurrent: newBedCurr,
              bedTarget: newBedTarg,
            );
          }
        }
      }
    });

    return const TemperatureState();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

final temperatureProvider =
    NotifierProvider<TemperatureNotifier, TemperatureState>(() {
      return TemperatureNotifier();
    });
