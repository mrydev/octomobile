import 'dart:convert';
import 'package:http/http.dart' as http;

class OctoPrintApiClient {
  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  OctoPrintApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'X-Api-Key': apiKey,
    'Content-Type': 'application/json',
  };

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl/api/$endpoint');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load data from $endpoint: ${response.statusCode}',
      );
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/$endpoint');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      throw Exception(
        'Failed to post data to $endpoint: ${response.statusCode}',
      );
    }
  }

  Future<void> setToolTemperature(
    double target, {
    String tool = 'tool0',
  }) async {
    await post('printer/tool', {
      'command': 'target',
      'targets': {tool: target},
    });
  }

  Future<void> setBedTemperature(double target) async {
    await post('printer/bed', {'command': 'target', 'target': target});
  }

  // === Extruder Controls ===
  Future<void> extrude(double amount) async {
    // A positive amount extrudes, a negative amount retracts
    await post('printer/tool', {'command': 'extrude', 'amount': amount});
  }

  // === Printhead Movement Controls ===

  Future<void> home(List<String> axes) async {
    await post('printer/printhead', {'command': 'home', 'axes': axes});
  }

  Future<void> jog({double? x, double? y, double? z, int? speed}) async {
    final Map<String, dynamic> body = {
      'command': 'jog',
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (z != null) 'z': z,
      if (speed != null) 'speed': speed,
    };
    await post('printer/printhead', body);
  }

  // === Files ===
  Future<List<dynamic>> getFiles() async {
    final response = await get('files/local');
    if (response != null && response['files'] != null) {
      return response['files'] as List<dynamic>;
    }
    return [];
  }

  Future<void> printFile(String filename) async {
    await post('files/local/$filename', {'command': 'select', 'print': true});
  }

  // === Job Control ===
  Future<void> cancelPrint() async {
    await post('job', {'command': 'cancel'});
  }

  Future<void> pausePrint() async {
    await post('job', {'command': 'pause', 'action': 'pause'});
  }

  Future<void> resumePrint() async {
    await post('job', {'command': 'pause', 'action': 'resume'});
  }

  // === Tuning Controls ===
  Future<void> setFeedrate(int factor) async {
    // factor is a percentage, e.g. 100 for 100%
    await post('printer/printhead', {'command': 'feedrate', 'factor': factor});
  }

  Future<void> setFlowrate(int factor) async {
    // factor is a percentage, e.g. 100 for 100%
    await post('printer/tool', {'command': 'flowrate', 'factor': factor});
  }

  // === Terminal / G-Code ===
  Future<void> sendCommand(String command) async {
    // OctoPrint /api/printer/command accepts a single command string
    // or a list of commands (via 'commands' key). We send one at a time.
    await post('printer/command', {'command': command});
  }
}
