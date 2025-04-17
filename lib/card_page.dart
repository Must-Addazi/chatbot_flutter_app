import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final List<Map<String, String>> _messages = [];
  final String userMessage = "Toucan";

  Map<String, dynamic>? birdData;
  bool isLoading = true;

  final String apiKey = ""; // 🔐 Remplace ou sécurise

  Future<void> askLargeLanguageModelDeepSeek() async {
    _messages.add({
      "role": "user",
      "content": """
Give me only a raw JSON object with no explanation or decoration. The format is:

{
  "name": "Bird's name",
  "habitat": "Its habitat",
  "alimentation": "What it eats",
  "image_url": "https://image.com",
  "anecdote": "A fun fact",
  "more_details": "A full description",
  "Weight": "...",
  "Color": "...",
  "Size": "...",
  "Lifespan": "...",
  "Offspring": "...",
  "Population": "..."
}

Respond only with a strictly valid JSON object. Do not wrap it in code blocks, nor add comments. The bird is: $userMessage.
""",
    });

    final requestBody = {
      "model": "deepseek/deepseek-r1-zero:free",
      "messages": [
        {"role": "system", "content": "Tu es un expert en ornithologie."},
        ..._messages,
      ],
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String botResponse = data['choices'][0]['message']['content'];
        print("botResponse = $botResponse");

        final match = RegExp(r'\{[\s\S]*\}').firstMatch(botResponse);
        if (match != null) {
          final jsonString = match.group(0)!;
          final parsedJson = jsonDecode(jsonString);

          setState(() {
            birdData = parsedJson;
            isLoading = false;
          });
        } else {
          print("❌ Aucun JSON détecté dans la réponse.");
          setState(() => isLoading = false);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Réponse API échouée : ${response.body}");
      }
    } catch (e) {
      print("Erreur de connexion ou de traitement : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    askLargeLanguageModelDeepSeek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bird Details"), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : birdData == null
              ? const Center(child: Text("Aucune donnée disponible."))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (birdData!['image_url'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: birdData!['image_url'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    const SizedBox(height: 20),

                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Features",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Données générales
                            ...birdData!.entries
                                .where(
                                  (e) =>
                                      e.key != 'image_url' &&
                                      e.key != 'more_details',
                                )
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${entry.key}:",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(entry.value.toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (birdData!['more_details'] != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Full description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              birdData!['more_details'],
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
