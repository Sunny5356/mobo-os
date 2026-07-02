import 'dart:convert';
import 'package:http/http.dart' as http;

class InsightsRepository {
  final String baseUrl;
  InsightsRepository({this.baseUrl = 'https://api.mobo.app/v1'});

  Future<Map<String, dynamic>> fetchSummary() async {
    final url = Uri.parse('$baseUrl/insights/summary');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception('Server error');
    } catch (e) {
      rethrow;
    }
  }
}
