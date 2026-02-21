import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            tooltip: 'Acil Durdurma (M112)',
            onPressed: () {
              if (settings == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bağlantı bulunamadı.')),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Acil Durdurma!'),
                  content: const Text(
                    'Yazıcıya M112 komutu gönderilecek. Bu işlem yazıcıyı anında durdurur ve yeniden başlatmanızı gerektirebilir. Emin misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Vazgeç'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        ref.read(apiClientProvider)?.sendCommand('M112');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'M112 Acil Durdurma Komutu Gönderildi!',
                            ),
                          ),
                        );
                      },
                      child: const Text('Tüm Sistemi Durdur'),
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
          children:
              const [
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
                Text(
                  'Tuning (Ayarlar)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
              ] +
              [const TuningControlWidget(), const SizedBox(height: 24)],
        ),
      ),
    );
  }
}
