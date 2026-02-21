import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/providers/connection_provider.dart';
import '../providers/temperature_provider.dart';
import 'temperature_gauge_widget.dart';

class TemperatureDashboardWidget extends ConsumerWidget {
  const TemperatureDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempState = ref.watch(temperatureProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: TemperatureGaugeWidget(
            title: '${l10n.nozzle} (T0)',
            currentTemp: tempState.toolCurrent,
            targetTemp: tempState.toolTarget,
            maxTemp: 300.0,
            activeColor: theme.colorScheme.error,
            onTap: () => _showSetTempDialog(
              context,
              ref,
              l10n,
              '${l10n.nozzle} (T0)',
              tempState.toolTarget > 0 ? tempState.toolTarget : 200.0,
              300.0,
              (val) {
                ref.read(apiClientProvider)?.setToolTemperature(val);
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TemperatureGaugeWidget(
            title: l10n.bed,
            currentTemp: tempState.bedCurrent,
            targetTemp: tempState.bedTarget,
            maxTemp: 120.0,
            activeColor: theme.colorScheme.primary,
            onTap: () => _showSetTempDialog(
              context,
              ref,
              l10n,
              l10n.bed,
              tempState.bedTarget > 0 ? tempState.bedTarget : 60.0,
              120.0,
              (val) {
                ref.read(apiClientProvider)?.setBedTemperature(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSetTempDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String title,
    double initialVal,
    double maxVal,
    Function(double) onSet,
  ) {
    double currentVal = initialVal;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('$title ${l10n.setTemp}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentVal.toInt()}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: currentVal,
                    max: maxVal,
                    divisions: maxVal.toInt(),
                    label: currentVal.round().toString(),
                    onChanged: (val) {
                      setState(() => currentVal = val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 40,
                        onPressed: () {
                          if (currentVal >= 5) setState(() => currentVal -= 5);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 40,
                        onPressed: () {
                          if (currentVal <= maxVal - 5) {
                            setState(() => currentVal += 5);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onSet(
                      0,
                    ); // Optional: Provide a way to turn it off completely
                    Navigator.pop(context);
                  },
                  child: Text(l10n.turnOff),
                ),
                FilledButton(
                  onPressed: () {
                    onSet(currentVal);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.setTemp),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
