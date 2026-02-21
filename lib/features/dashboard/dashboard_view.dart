import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/providers/connection_provider.dart';
import 'widgets/webcam_stream_widget.dart';
import 'widgets/print_progress_widget.dart';
import '../temperature/widgets/temperature_dashboard_widget.dart';
import 'widgets/movement_control_widget.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Just for demonstrating how to trigger connection in dev
    // In a real app this would be in a settings/login page
    final settings = ref.watch(connectionSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
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
                    .state = ConnectionSettings(
                  baseUrl: 'http://192.168.1.156',
                  apiKey: 'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0',
                  wsUrl: 'ws://192.168.1.156/sockjs/websocket',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OctoPrint\'e Bağlanıldı (192.168.1.156)'),
                  ),
                );
              } else {
                ref.read(connectionSettingsProvider.notifier).state = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bağlantı Kesildi')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            WebcamStreamWidget(),
            SizedBox(height: 24),
            Text(
              'Temperatures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TemperatureDashboardWidget(),
            SizedBox(height: 24),
            Text(
              'Print Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            PrintProgressWidget(),
            SizedBox(height: 24),
            Text(
              'Movement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            MovementControlWidget(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
