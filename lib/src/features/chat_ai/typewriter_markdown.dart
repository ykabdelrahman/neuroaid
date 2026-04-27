import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A widget that displays Markdown text with a typewriter animation effect.
/// The text reveals itself character by character, simulating a typing effect.
class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? textColor;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    this.textStyle,
    this.textColor,
    this.speed = const Duration(milliseconds: 20),
    this.onComplete,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    final duration = widget.speed * widget.text.length;

    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))
      ..addListener(() {
        if (mounted) {
          setState(() {
            _displayedText = widget.text.substring(0, _characterCount.value);
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.onComplete != null) {
          widget.onComplete!();
        }
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(TypewriterMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayedText,
      styleSheet: MarkdownStyleSheet(
        p: widget.textStyle ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 14,
              height: 1.5,
            ),
        strong: widget.textStyle?.copyWith(
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
        em: widget.textStyle?.copyWith(
              fontStyle: FontStyle.italic,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
        code: TextStyle(
          backgroundColor: Colors.grey.shade200,
          color: widget.textColor ?? const Color(0xFF0E7772),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        listBullet: widget.textStyle?.copyWith(
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
        blockquotePadding: const EdgeInsets.only(left: 12),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: widget.textColor ?? const Color(0xFF0E7772),
              width: 3,
            ),
          ),
        ),
        h1: widget.textStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
        h2: widget.textStyle?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
        h3: widget.textStyle?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              color: widget.textColor ?? const Color(0xFF0E7772),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
