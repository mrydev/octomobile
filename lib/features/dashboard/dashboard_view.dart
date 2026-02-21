import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../connection/providers/connection_provider.dart';
import 'widgets/webcam_stream_widget.dart';
import 'widgets/print_progress_widget.dart';
import '../temperature/widgets/temperature_dashboard_widget.dart';
import 'widgets/movement_control_widget.dart';
import 'widgets/tuning_control_widget.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Just for demonstrating how to trigger connection in dev
    // In a real app this would be in a settings/login page
    final settings = ref.watch(connectionSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            tooltip: l10n.emergencyStop,
            onPressed: () {
              if (settings == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.connectionNotFound)),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.emergencyStop),
                  content: Text(l10n.emergencyStopDesc),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancelAction),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        ref.read(apiClientProvider)?.sendCommand('M112');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.emergencySent)),
                        );
                      },
                      child: Text(l10n.stopSystem),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              settings != null ? Icons.wifi : Icons.wifi_off,
              color: settings != null ? Colors.greenAccent : Colors.redAccent,
            ),
            onPressed: () {
              if (settings == null) {
                // Real connection for local testing
                ref
                    .read(connectionSettingsProvider.notifier)
                    .connect(
                      'http://192.168.1.156',
                      'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0',
                      'ws://192.168.1.156/sockjs/websocket',
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.connectedTo} (192.168.1.156)'),
                  ),
                );
              } else {
                ref.read(connectionSettingsProvider.notifier).disconnect();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.disconnected)));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const WebcamStreamWidget(),
            const SizedBox(height: 24),
            Text(
              l10n.temperatures,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const TemperatureDashboardWidget(),
            const SizedBox(height: 24),
            Text(
              l10n.printStatus,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const PrintProgressWidget(),
            const SizedBox(height: 24),
            Text(
              l10n.movement,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const MovementControlWidget(),
            const SizedBox(height: 24),
            Text(
              l10n.tuning,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const TuningControlWidget(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
