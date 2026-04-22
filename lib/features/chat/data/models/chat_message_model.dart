import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageBytes,
  });
}
