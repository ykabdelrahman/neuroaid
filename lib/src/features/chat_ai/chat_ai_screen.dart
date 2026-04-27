import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/features/chat_ai/ChatBubble.dart';
import 'package:neuroaid/src/features/chat_ai/ChatMessage.dart';
import 'package:neuroaid/src/core/services/api_service.dart';
import 'package:neuroaid/src/core/services/chat_service.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessageModel> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConversationStarted = false;
  bool _isTyping = false;
  late final ChatService _chatService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(ApiService());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startConversation(String initialMessage) {
    setState(() {
      _isConversationStarted = true;
    });

    // Send the initial message
    Future.delayed(const Duration(milliseconds: 300), () {
      _sendMessage(initialMessage);
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = ChatMessageModel(
      text: text,
      isSender: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _isTyping = true;
      _errorMessage = null;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Get conversation history for context
      final conversationHistory = ChatService.formatConversationHistory(
        _messages,
      );

      // Send message to AI chatbot
      final aiResponse = await _chatService.sendMessage(
        text,
        conversationHistory: conversationHistory,
      );

      if (!mounted) return;

      final botMessage = ChatMessageModel(
        text: aiResponse,
        isSender: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // Show error message in chat
      final errorBotMessage = ChatMessageModel(
        text:
            'عذراً، حدث خطأ: ${_errorMessage ?? "لم أتمكن من الرد. يرجى المحاولة مرة أخرى."}',
        isSender: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorBotMessage);
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header - يتغير حجمه بناءً على الحالة
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: _isConversationStarted
                ? 80 + MediaQuery.of(context).padding.top
                : MediaQuery.of(context).size.height * 0.32,
            decoration: BoxDecoration(
              color: _isConversationStarted
                  ? Colors.white
                  : const Color(0xFF0E7772),
              borderRadius: _isConversationStarted
                  ? null
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
              boxShadow: _isConversationStarted
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: EdgeInsets.all(_isConversationStarted ? 10 : 14),
                      decoration: BoxDecoration(
                        color: _isConversationStarted
                            ? const Color(0xFFF5F5F5)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          _isConversationStarted ? 10 : 12,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.robot,
                        color: _isConversationStarted
                            ? const Color(0xFF0E7772)
                            : Colors.white,
                        size: _isConversationStarted ? 22 : 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        color: _isConversationStarted
                            ? Colors.black87
                            : Colors.white,
                        fontSize: _isConversationStarted ? 20 : 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      child: const Text('Chatbot'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: Stack(
              children: [
                // Suggestion Cards - تختفي عند بدء المحادثة
                AnimatedOpacity(
                  opacity: _isConversationStarted ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _isConversationStarted
                        ? const Offset(0, -0.3)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: _isConversationStarted,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSuggestionCard(
                                'Can you help me, please?',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSuggestionCard(
                                'Can you help me, please?',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Chat Messages - تظهر عند بدء المحادثة
                AnimatedOpacity(
                  opacity: _isConversationStarted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedSlide(
                    offset: _isConversationStarted
                        ? Offset.zero
                        : const Offset(0, 0.1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: IgnorePointer(
                      ignoring: !_isConversationStarted,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildChatBubble(_messages[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String text) {
    return InkWell(
      onTap: () => _startConversation(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel message) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(message.timestamp),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          alignment: message.isSender
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: ChatBubble(message: message),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFE0F7F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              onEnd: () {
                if (mounted) setState(() {});
              },
              builder: (context, value, child) {
                final delay = index * 0.2;
                final animValue = ((value - delay) % 1.0).clamp(0.0, 1.0);
                final opacity = animValue < 0.5
                    ? animValue * 2
                    : (1 - animValue) * 2;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0E7772,
                    ).withOpacity(0.3 + (opacity * 0.7)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message Chatbot...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB), // subtle grey
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E7772), // primary teal
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          suffixIcon: Builder(
                            builder: (context) {
                              return (_controller.text.isNotEmpty)
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF9CA3AF),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _controller.clear();
                                        setState(() {});
                                      },
                                      tooltip: 'Clear',
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),
                        onSubmitted: (text) {
                          if (!_isConversationStarted) {
                            _startConversation(text);
                          } else {
                            _sendMessage(text);
                          }
                        },
                      ),
                    ),

                    if (_controller.text.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E7772),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.paperPlane,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (!_isConversationStarted) {
                              _startConversation(_controller.text);
                            } else {
                              _sendMessage(_controller.text);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                final text = _controller.text;
                if (!_isConversationStarted) {
                  _startConversation(text);
                } else {
                  _sendMessage(text);
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E7772),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.paperPlane,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
