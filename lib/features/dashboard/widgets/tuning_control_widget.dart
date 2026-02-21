import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';

class TuningControlWidget extends ConsumerStatefulWidget {
  const TuningControlWidget({super.key});

  @override
  ConsumerState<TuningControlWidget> createState() =>
      _TuningControlWidgetState();
}

class _TuningControlWidgetState extends ConsumerState<TuningControlWidget> {
  int _feedrate = 100;
  int _flowrate = 100;

  void _updateFeedrate(int change) {
    setState(() {
      _feedrate = (_feedrate + change).clamp(10, 300);
    });
    ref.read(apiClientProvider)?.setFeedrate(_feedrate);
  }

  void _updateFlowrate(int change) {
    setState(() {
      _flowrate = (_flowrate + change).clamp(10, 300);
    });
    ref.read(apiClientProvider)?.setFlowrate(_flowrate);
  }

  void _resetTuning() {
    setState(() {
      _feedrate = 100;
      _flowrate = 100;
    });
    ref.read(apiClientProvider)?.setFeedrate(100);
    ref.read(apiClientProvider)?.setFlowrate(100);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTuneRow('Yazdırma Hızı (Dış)', _feedrate, _updateFeedrate),
            const Divider(height: 24),
            _buildTuneRow('Akış Hızı (İç)', _flowrate, _updateFlowrate),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _feedrate == 100 && _flowrate == 100
                    ? null
                    : _resetTuning,
                child: const Text('Değerleri Sıfırla (%100)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTuneRow(String title, int value, Function(int) onChange) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '%$value',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              onPressed: () => onChange(-10),
              icon: const Icon(Icons.remove),
              tooltip: '-10%',
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => onChange(-1),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.remove, size: 16),
              tooltip: '-1%',
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => onChange(1),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.add, size: 16),
              tooltip: '+1%',
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => onChange(10),
              icon: const Icon(Icons.add),
              tooltip: '+10%',
            ),
          ],
        ),
      ],
    );
  }
}
