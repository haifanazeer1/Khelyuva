import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chatbotrepo.dart';

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

//Notifier
class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotRepository _repo;

  ChatbotNotifier(this._repo) : super(const ChatbotState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add user message immediately to UI
    final userMsg = ChatMessage(type: 'user', text: text.trim());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      // 2. Call FastAPI
      final reply = await _repo.sendMessage(
        message: text.trim(),
        history: state.messages,
      );

      // 3. Add bot reply
      final botMsg = ChatMessage(type: 'bot', text: reply);
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      // 4. error message for Ui to stay consistent
      final errorMsg = ChatMessage(
        type: 'bot',
        text: 'Sorry, I couldn\'t connect. Please try again. 🔌',
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() => state = const ChatbotState();
}

//Providers
final chatbotRepositoryProvider = Provider<ChatbotRepository>(
  (_) => ChatbotRepository(),
);

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref.watch(chatbotRepositoryProvider));
});
