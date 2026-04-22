import 'dart:typed_data';
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
      model: 'gemini-flash-latest', // Multi-modal capable model
      apiKey: apiKey ?? '',
      systemInstruction: Content.system(
        "You are AI Doctor, a professional and empathetic medical assistant for HealthGen AI. "
        "Your goal is to help users understand symptoms, suggest home remedies, and explain medicines. "
        "You can analyze medical images like prescriptions, lab reports, or symptom photos. "
        "Maintain a professional, calming, and concise tone. "
        "Respond in the language the user uses (English, Hindi, or Hinglish). "
        "Strict Rule: Always include this disclaimer at the end of medical advice: "
        "\n\n*Note: I am an AI, not a replacement for a professional doctor. In case of emergency, please visit a hospital immediately.*"
      ),
    );

    _session = _model.startChat();
  }

  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    // 1. Add User Message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
    );
    state = [...state, userMessage];

    try {
      // 2. Prepare content
      final content = imageBytes != null
          ? [
              Content.multi([
                TextPart(text),
                DataPart('image/jpeg', imageBytes),
              ])
            ]
          : [Content.text(text)];

      // 3. Call AI
      // Note: We use sendMessage for continuous chat, but if it fails for multi-modal, we handle it
      final response = await _session?.sendMessage(content.first);
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
          text: "I'm sorry, I'm having trouble analyzing this right now. Please check if the image is clear and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ];
    }
  }

  void clearChat() {
    state = [];
    _session = _model.startChat();
  }
}
