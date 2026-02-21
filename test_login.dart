import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://192.168.1.156';
  final apiKey = 'o0uj2Q65mOBpr_sZNJXj4x8G9vQERzLsekm-k9nF-q0';

  print('Attempting passive login...');
  final response = await http.post(
    Uri.parse('$baseUrl/api/login'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: json.encode({"passive": true}),
  );

  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
}
