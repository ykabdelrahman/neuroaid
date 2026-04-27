// Chat Message Model
class ChatMessageModel {
  final String text;
  final bool isSender;
  final DateTime timestamp;

  ChatMessageModel({
    required this.text,
    required this.isSender,
    required this.timestamp,
  });
}
