import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthgenai/features/chat/data/models/chat_message_model.dart';
import 'dart:developer' as dev;

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

class ChatNotifier extends Notifier<List<ChatMessage>> {
  late final GenerativeModel _model;
  ChatSession? _session;

  @override
  List<ChatMessage> build() {
    _initModel();
    return [];
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey == 'YOUR_API_KEY_HERE') {
      dev.log('Warning: Gemini API Key is missing or default.');
    }

    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey ?? '',
      systemInstruction: Content.system(
        "You are AI Doctor, a professional and empathetic medical assistant for HealthGen AI. "
        "Your goal is to help users understand symptoms, suggest home remedies, and explain medicines. "
        "Maintain a professional, calming, and concise tone. "
        "Respond in the language the user uses (English, Hindi, or Hinglish). "
        "Strict Rule: Always include this disclaimer at the end of medical advice: "
        "\n\n*Note: I am an AI, not a replacement for a professional doctor. In case of emergency, please visit a hospital immediately.*"
      ),
    );

    _session = _model.startChat();
  }

  Future<void> sendMessage(String text) async {
    // 1. Add User Message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    try {
      // 2. Add a placeholder AI message for "typing" effect if needed (Optional, handled in UI)
      
      // 3. Call AI
      final response = await _session?.sendMessage(Content.text(text));
      final aiText = response?.text;

      if (aiText != null) {
        final aiMessage = ChatMessage(
          text: aiText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = [...state, aiMessage];
      }
    } catch (e) {
      dev.log('Error sending message to Gemini: $e');
      state = [
        ...state,
        ChatMessage(
          text: "I'm sorry, I'm having trouble connecting right now. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ];
    }
  }
}
