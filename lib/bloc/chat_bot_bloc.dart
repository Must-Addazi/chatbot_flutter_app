import 'package:bloc/bloc.dart';
import 'package:chat_boot_app/model/message.dart';
import 'package:chat_boot_app/repository/chatbot_repository.dart';

/// 🔁 Event base class
abstract class ChatBotEvent {}

/// 📩 Event: User sends a query
class AskLLMEvent extends ChatBotEvent {
  final String query;
  AskLLMEvent(this.query);
}

/// 📦 State base class
abstract class ChatBotState {
  final List<Message> messages;
  ChatBotState(this.messages);
}

/// ⏳ Pending response
class ChatBotPendingState extends ChatBotState {
  ChatBotPendingState(super.messages);
}

/// ✅ Success state
class ChatBotSuccessState extends ChatBotState {
  ChatBotSuccessState(super.messages);
}

/// ❌ Error state
class ChatBotErrorState extends ChatBotState {
  final String errorMessage;
  ChatBotErrorState(super.messages, this.errorMessage);
}

/// 🟢 Initial state
class ChatBotInitialState extends ChatBotState {
  ChatBotInitialState()
    : super([
        Message("user", "Hello"),
        Message("assistant", "How can I help?"),
      ]);
}

/// 🤖 ChatBotBloc
class ChatBotBloc extends Bloc<ChatBotEvent, ChatBotState> {
  final ChatbotRepository chatbotRepository = ChatbotRepository();
  late ChatBotEvent lastEvent;

  ChatBotBloc() : super(ChatBotInitialState()) {
    on<AskLLMEvent>((event, emit) async {
      print("🔄 AskLLMEvent triggered");
      lastEvent = event;

      // Copy current messages to avoid mutating original state
      final List<Message> currentMessages = List<Message>.from(state.messages);
      currentMessages.add(Message("user", event.query));

      emit(ChatBotPendingState(currentMessages));

      try {
        final Message? responseMessage = await chatbotRepository
            .askLargeLanguageModelDeepSeek(event.query);

        if (responseMessage != null) {
          currentMessages.add(responseMessage);
          emit(ChatBotSuccessState(currentMessages));
        } else {
          emit(
            ChatBotErrorState(currentMessages, "No response from assistant."),
          );
        }
      } catch (e) {
        emit(ChatBotErrorState(currentMessages, e.toString()));
      }
    });
  }
}
