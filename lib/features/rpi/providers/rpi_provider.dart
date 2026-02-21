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
  final bool isConnecting;
  final RpiStats stats;
  final String error;

  const RpiState({
    this.client,
    this.isConnecting = false,
    this.stats = const RpiStats(),
    this.error = '',
  });

  RpiState copyWith({
    SSHClient? client,
    bool? isConnecting,
    RpiStats? stats,
    String? error,
  }) {
    return RpiState(
      client: client ?? this.client,
      isConnecting: isConnecting ?? this.isConnecting,
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
      // Get CPU temperature
      final tempResult = await client.run(
        'cat /sys/class/thermal/thermal_zone0/temp',
      );
      final cpuTempStr = String.fromCharCodes(tempResult).trim();
      final cpuTemp = (double.tryParse(cpuTempStr) ?? 0.0) / 1000.0;

      // Get CPU usage (basic calculation)
      final cpuUsageResult = await client.run(
        "top -bn1 | grep 'Cpu(s)' | awk '{print \$2 + \$4}'",
      );
      final cpuUsage =
          double.tryParse(String.fromCharCodes(cpuUsageResult).trim()) ?? 0.0;

      // Get RAM usage
      final ramResult = await client.run(
        "free -m | awk 'NR==2{printf \"%.2f %d/%d MB\", \$3*100/\$2, \$3, \$2}'",
      );
      final ramOutput = String.fromCharCodes(ramResult).trim();
      final ramParts = ramOutput.split(' ');
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
