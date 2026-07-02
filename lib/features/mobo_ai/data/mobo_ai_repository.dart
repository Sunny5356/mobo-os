import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai_message.dart';

class MoboAiRepository {
  final String baseUrl;
  MoboAiRepository({this.baseUrl = 'https://api.mobo.app/v1'});

  Future<AiMessage> sendMessage(String conversationId, String content) async {
    final url = Uri.parse('$baseUrl/ai/conversations/$conversationId/messages');
    try {
      final res = await http.post(url, body: jsonEncode({'content': content}), headers: {'Content-Type': 'application/json'});
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AiMessage.fromJson(data);
      }
      throw Exception('AI error');
    } catch (e) {
      // Fallback: return a mocked assistant message suggesting a reminder action for demo
      return AiMessage.mockAssistantSuggestReminder();
    }
  }

  Future<void> confirmAction(String messageId) async {
    final url = Uri.parse('$baseUrl/ai/actions/$messageId/confirm');
    await http.post(url);
  }

  Future<void> rejectAction(String messageId) async {
    final url = Uri.parse('$baseUrl/ai/actions/$messageId/reject');
    await http.post(url);
  }
}
