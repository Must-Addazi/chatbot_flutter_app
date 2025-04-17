import 'package:chat_boot_app/bloc/chat_bot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBootPage extends StatelessWidget {
  ChatBootPage({super.key});
  final ScrollController scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  String lastQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatBot OpenRouter"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            // Correction : éviter les erreurs de hauteur
            child: BlocBuilder<ChatBotBloc, ChatBotState>(
              builder: (context, state) {
                if (state is ChatBotPendingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ChatBotErrorState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Erreur : ${state.errorMessage}",
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (lastQuery.isNotEmpty) {
                            context.read<ChatBotBloc>().add(
                              AskLLMEvent(lastQuery),
                            );
                          }
                        },
                        child: Text("Réessayer"),
                      ),
                    ],
                  );
                } else if (state is ChatBotSuccessState ||
                    state is ChatBotInitialState) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    controller: scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isUser = message.role == "user";

                      return Align(
                        alignment:
                            isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.content!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
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
                      lastQuery = text; // Stocker la requête pour le retry
                      context.read<ChatBotBloc>().add(AskLLMEvent(text));
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
