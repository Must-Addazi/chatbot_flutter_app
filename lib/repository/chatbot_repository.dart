import 'dart:convert';
import 'package:chat_boot_app/model/message.dart';
import 'package:http/http.dart' as http;

class ChatbotRepository {
  final List<Map<String, String>> _messages = [];

  // ⚠️ Remplace cette clé par un système sécurisé plus tard (comme dotenv)
  final String apiKey = "";

  Future<Message?> askLargeLanguageModelDeepSeek(String userMessage) async {
    _messages.add({
      "role": "user",
      "content": """
If the value provided for $userMessage does not refer to a bird or is not related to birds, reply strictly with the following sentence:

"Sorry, I only support birds."

The bird is: $userMessage
""",
    });

    final requestBody = {
      "model": "deepseek/deepseek-r1-zero:free",
      "messages": [
        {"role": "system", "content": "Tu es un expert en ornithologie."},
        ..._messages.map(
          (msg) => {
            "role": msg["role"] ?? "user",
            "content": msg["content"] ?? "",
          },
        ),
      ],
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://domain.com",
          "X-Title": "Flutter ChatBot",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String botResponse = utf8.decode(
          latin1.encode(data['choices'][0]['message']['content']),
        );

        // 🧼 Clean any unwanted formatting
        final cleanResponse = botResponse
            .replaceAll(r'\boxed{', '')
            .replaceAll('}', '');

        print("response: $cleanResponse");

        return Message("assistant", cleanResponse);
      } else {
        print("❌ Erreur API ${response.statusCode}: ${response.body}");
        return Message(
          "assistant",
          "An error occurred. Please try again later.",
        );
      }
    } catch (e) {
      print("❌ Erreur lors de l'appel API : $e");
      return Message("assistant", "Something went wrong: $e");
    }
  }
}
