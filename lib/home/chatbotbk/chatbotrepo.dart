import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String type;
  final String text;

  ChatMessage({required this.type, required this.text});

  Map<String, dynamic> toHistoryJson() => {
        'role': type == 'user' ? 'user' : 'assistant',
        'content': text,
      };
}

class ChatbotRepository {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // ← this must be first
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
        return 'http://localhost:8000';
      default:
        return 'http://localhost:8000';
    }
  }

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'conversation_history':
                history.map((m) => m.toHistoryJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Server error');
    }
  }
}
