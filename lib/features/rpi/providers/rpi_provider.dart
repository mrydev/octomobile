import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';

class RpiCredentials {
  final String host;
  final String username;
  final String password;

  RpiCredentials({
    required this.host,
    required this.username,
    required this.password,
  });
}

class RpiStats {
  final double cpuTemp;
  final double cpuUsage;
  final double ramUsagePercent;
  final String ramText;

  const RpiStats({
    this.cpuTemp = 0.0,
    this.cpuUsage = 0.0,
    this.ramUsagePercent = 0.0,
    this.ramText = '0MB / 0MB',
  });
}

class RpiState {
  final SSHClient? client;
  final SSHSession? shell;
  final bool isConnecting;
  final bool isTerminalActive;
  final RpiStats stats;
  final String error;

  const RpiState({
    this.client,
    this.shell,
    this.isConnecting = false,
    this.isTerminalActive = false,
    this.stats = const RpiStats(),
    this.error = '',
  });

  RpiState copyWith({
    SSHClient? client,
    SSHSession? shell,
    bool? isConnecting,
    bool? isTerminalActive,
    RpiStats? stats,
    String? error,
    bool clearShell = false,
  }) {
    return RpiState(
      client: client ?? this.client,
      shell: clearShell ? null : (shell ?? this.shell),
      isConnecting: isConnecting ?? this.isConnecting,
      isTerminalActive: isTerminalActive ?? this.isTerminalActive,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class RpiNotifier extends StateNotifier<RpiState> {
  Timer? _statsTimer;

  RpiNotifier() : super(RpiState()) {
    _loadAndConnect();
  }

  Future<void> _loadAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('rpi_host');
    final username = prefs.getString('rpi_username');
    final password = prefs.getString('rpi_password');

    if (host != null && username != null && password != null) {
      connect(host, username, password);
    }
  }

  Future<void> connect(String host, String username, String password) async {
    state = state.copyWith(isConnecting: true, error: '');

    // Save credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpi_host', host);
    await prefs.setString('rpi_username', username);
    await prefs.setString('rpi_password', password);

    try {
      final client = SSHClient(
        await SSHSocket.connect(host, 22),
        username: username,
        onPasswordRequest: () => password,
      );

      state = state.copyWith(client: client, isConnecting: false);

      _startStatsTimer();
    } catch (e) {
      state = state.copyWith(isConnecting: false, error: e.toString());
    }
  }

  Future<void> startTerminal() async {
    final client = state.client;
    if (client == null) return;

    try {
      final shell = await client.shell();
      state = state.copyWith(shell: shell, isTerminalActive: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to start terminal: $e');
    }
  }

  void closeTerminal() {
    state.shell?.close();
    state = state.copyWith(clearShell: true, isTerminalActive: false);
  }

  void _startStatsTimer() {
    _statsTimer?.cancel();
    _fetchStats(); // Fetch immediately
    _statsTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchStats(),
    );
  }

  Future<void> _fetchStats() async {
    final client = state.client;
    if (client == null) return;

    try {
      final cmd =
          "cat /sys/class/thermal/thermal_zone0/temp && echo '---' && top -bn1 | grep 'Cpu(s)' | awk '{print \$2 + \$4}' && echo '---' && free -m | awk 'NR==2{printf \"%.2f %d/%d MB\", \$3*100/\$2, \$3, \$2}'";
      final result = await client.run(cmd);
      final output = String.fromCharCodes(result).trim();
      final sections = output.split('---');

      if (sections.length >= 3) {
        final cpuTempStr = sections[0].trim();
        final cpuTemp = (double.tryParse(cpuTempStr) ?? 0.0) / 1000.0;

        final cpuUsageStr = sections[1].trim();
        final cpuUsage = double.tryParse(cpuUsageStr) ?? 0.0;

        final ramStr = sections[2].trim();
        final ramParts = ramStr.split(' ');
        final ramUsagePercent = double.tryParse(ramParts[0]) ?? 0.0;
        final ramText = ramParts.length > 1
            ? ramParts.sublist(1).join(' ')
            : '0MB / 0MB';

        state = state.copyWith(
          stats: RpiStats(
            cpuTemp: cpuTemp,
            cpuUsage: cpuUsage,
            ramUsagePercent: ramUsagePercent,
            ramText: ramText,
          ),
        );
      }
    } catch (e) {
      // Silent error for periodic stats, but could log it if needed
    }
  }

  void disconnect() {
    _statsTimer?.cancel();
    state.client?.close();
    state = RpiState();
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    state.client?.close();
    super.dispose();
  }
}

final rpiProvider = StateNotifierProvider<RpiNotifier, RpiState>((ref) {
  return RpiNotifier();
});
