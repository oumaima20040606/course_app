import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? "YOUR_KEY";

  Future<String> summarizeText(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "system", "content": "You are a concise summarizer for educational PDFs."},
          {"role": "user", "content": "Summarize the following text: $text"}
        ],
        "max_tokens": 400
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception("AI API error: ${response.body}");
    }
  }
}
