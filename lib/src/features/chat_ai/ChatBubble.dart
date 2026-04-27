// Chat Bubble Widget
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:neuroaid/src/features/chat_ai/ChatMessage.dart';
import 'package:neuroaid/src/features/chat_ai/typewriter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isSender
              ? const Color(0xFF0E7772)
              : const Color(0xFFE0F7F7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isSender ? 18 : 4),
            bottomRight: Radius.circular(message.isSender ? 4 : 18),
          ),
        ),
        child: message.isSender
            ? _buildUserMessage()
            : _buildBotMessage(),
      ),
    );
  }

  /// Builds the user message with static Markdown rendering
  Widget _buildUserMessage() {
    return MarkdownBody(
      data: message.text,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
        ),
        strong: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
        code: TextStyle(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        listBullet: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        blockquoteDecoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the bot message with typewriter effect
  Widget _buildBotMessage() {
    return TypewriterMarkdown(
      text: message.text,
      textColor: const Color(0xFF0E7772),
      textStyle: const TextStyle(
        color: Color(0xFF0E7772),
        fontSize: 14,
        height: 1.5,
      ),
      speed: const Duration(milliseconds: 20),
    );
  }
}
