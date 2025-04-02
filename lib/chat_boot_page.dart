import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBootPage extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatBootPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final String apiKey =
      "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";

  Future<void> sendMessage(String userMessage) async {
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _isLoading = true;
    });

    final Map<String, dynamic> requestBody = {
      "model": "deepseek/deepseek-r1-zero:free",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a helpful assistant. Respond in clear, simple language.",
        },
        ..._messages.map(
          (msg) => {"role": msg["role"], "content": msg["content"]},
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
          "HTTP-Referer": "https://yourdomain.com",
          "X-Title": "Flutter ChatBot",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String botResponse =
            responseData['choices'][0]['message']['content'];
        print("response $botResponse");

        setState(() {
          _messages.add({"role": "assistant", "content": botResponse});
        });
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'appel API : $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ChatBot OpenRouter")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["content"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écris un message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
