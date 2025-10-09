import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://congenial-capybara-q76pvvx76v7j29w5v-3001.app.github.dev/api/v1"; // change for your server-api

  Future<dynamic> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch data: ${response.body}');
      throw Exception("Failed to fetch data");
    }
  }

  Future<dynamic> postData(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Failed to send data to $endpoint: ${response.statusCode} ${response.body}');
      throw Exception("Failed to send data");
    }
  }
}
