import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';
import 'package:dartssh2/dartssh2.dart';
import '../../l10n/app_localizations.dart';
import 'providers/rpi_provider.dart';
import 'widgets/rpi_stat_card_widget.dart';

class RpiView extends ConsumerStatefulWidget {
  const RpiView({super.key});

  @override
  ConsumerState<RpiView> createState() => _RpiViewState();
}

class _RpiViewState extends ConsumerState<RpiView> {
  final _hostController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  Terminal? _terminal;

  @override
  void initState() {
    super.initState();
  }

  void _setupTerminalIfNeeded(SSHSession? shell) {
    if (shell == null) {
      _terminal = null;
      return;
    }

    if (_terminal != null) return; // Already setup

    _terminal = Terminal();

    // Read from SSH shell and write to terminal
    shell.stdout.listen(
      (data) {
        _terminal!.write(String.fromCharCodes(data));
      },
      onError: (error) {
        _terminal!.write('\r\n[SSH Error: $error]\r\n');
      },
      onDone: () {
        _terminal!.write('\r\n[SSH Disconnected]\r\n');
      },
    );

    // Read from terminal (user input) and write to SSH shell
    _terminal!.onOutput = (text) {
      shell.write(Uint8List.fromList(text.codeUnits));
    };

    // Forward terminal resizes to SSH shell
    _terminal!.onResize = (width, height, pixelWidth, pixelHeight) {
      shell.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };
  }

  @override
  void dispose() {
    _hostController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _connect() {
    ref
        .read(rpiProvider.notifier)
        .connect(
          _hostController.text.trim(),
          _userController.text.trim(),
          _passController.text,
        );
  }

  void _disconnect() {
    ref.read(rpiProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the shell state strictly to setup terminal once
    ref.listen<RpiState>(rpiProvider, (previous, next) {
      if (previous?.shell != next.shell) {
        setState(() {
          _setupTerminalIfNeeded(next.shell);
        });
      }
    });

    final hasClient = ref.watch(rpiProvider.select((s) => s.client != null));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rpiTab),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (hasClient)
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: _disconnect,
              tooltip: l10n.disconnect,
            ),
        ],
      ),
      body: !hasClient ? _buildConnectForm(l10n) : _buildDashboard(l10n),
    );
  }

  Widget _buildConnectForm(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final isConnecting = ref.watch(
          rpiProvider.select((s) => s.isConnecting),
        );
        final error = ref.watch(rpiProvider.select((s) => s.error));

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.router_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.connectSsh,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    labelText: l10n.rpiHost,
                    prefixIcon: const Icon(Icons.dns),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.password),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FilledButton(
                  onPressed: isConnecting ? null : _connect,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isConnecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.connect),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboard(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.systemResources,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // stats gauge row via Consumer, so the terminal itself isn't rebuilt
          Consumer(
            builder: (context, ref, child) {
              final stats = ref.watch(rpiProvider.select((s) => s.stats));
              return Column(
                children: [
                  Column(
                    children: [
                      RpiStatCardWidget(
                        title: 'CPU Sıcaklığı',
                        valueText: '${stats.cpuTemp.toStringAsFixed(1)}°C',
                        percentage: stats.cpuTemp / 100.0,
                        color: stats.cpuTemp > 80
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        icon: Icons.thermostat_rounded,
                      ),
                      const SizedBox(height: 16),
                      RpiStatCardWidget(
                        title: 'CPU Kullanımı',
                        valueText: '${stats.cpuUsage.toStringAsFixed(1)}%',
                        percentage: stats.cpuUsage / 100.0,
                        color: Colors.orangeAccent,
                        icon: Icons.memory_rounded,
                      ),
                      const SizedBox(height: 16),
                      RpiStatCardWidget(
                        title: 'RAM Bellek',
                        valueText: stats.ramText,
                        percentage: stats.ramUsagePercent / 100.0,
                        color: theme.colorScheme.secondary,
                        icon: Icons.speed_rounded,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              final isTerminalActive = ref.watch(
                rpiProvider.select((s) => s.isTerminalActive),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.sshTerminal,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isTerminalActive,
                        onChanged: (val) {
                          if (val) {
                            ref.read(rpiProvider.notifier).startTerminal();
                          } else {
                            ref.read(rpiProvider.notifier).closeTerminal();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isTerminalActive)
                    SizedBox(
                      height: 300, // Fixed height for terminal when active
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.surfaceContainerHighest,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(8),
                        child: _terminal != null
                            ? TerminalView(
                                _terminal!,
                                textStyle: const TerminalStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  if (!isTerminalActive)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.terminal_rounded,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terminal Kapalı',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
