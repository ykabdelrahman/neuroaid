import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

const _systemPrompt =
    'You are NURO, an AI medical assistant specialized in stroke prevention, '
    'detection, and education. You help users understand stroke risk factors, '
    'recognize FAST symptoms (Face drooping, Arm weakness, Speech difficulty, '
    'Time to call emergency services), and provide evidence-based health '
    'guidance. Always recommend consulting a healthcare professional for '
    'personal medical decisions.';

class ChatService {
  late final Dio _dio;

  ChatService([_]) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.openRouterBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
          'HTTP-Referer': 'https://neuroaid.app',
          'X-Title': 'NeuroAid',
        },
      ),
    );
  }

  /// Send a message to the AI chatbot and return the full response text.
  ///
  /// Uses OpenRouter's OpenAI-compatible streaming endpoint so the existing
  /// UI (which expects a `Future<String>`) needs no changes.
  Future<String> sendMessage(
    String message, {
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      log('💬 Sending message via OpenRouter: $message');

      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._buildHistory(conversationHistory),
        {'role': 'user', 'content': message},
      ];

      final response = await _dio.post(
        ApiConstants.openRouterChatEndpoint,
        data: {
          'model': ApiConstants.openRouterModel,
          'messages': messages,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final responseBody = response.data as ResponseBody;
      final buffer = StringBuffer();

      await for (final chunk in responseBody.stream) {
        final text = utf8.decode(chunk, allowMalformed: true);
        for (final line in text.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;

          final payload = trimmed.substring(6);
          if (payload == '[DONE]') continue;

          try {
            final json = jsonDecode(payload) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null) buffer.write(content);
          } catch (_) {
            // Malformed chunk — skip
          }
        }
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) throw Exception('Empty response from chatbot');

      log('✅ OpenRouter response received (${result.length} chars)');
      return result;
    } on DioException catch (e) {
      log('❌ DioException in sendMessage: ${e.message}');
      log('❌ Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to chatbot service.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Chatbot authentication failed. Please contact support.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      }

      throw Exception('Failed to send message. Please try again.');
    } catch (e) {
      log('❌ Unexpected error in sendMessage: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Convert the app's conversation history to OpenAI's messages format.
  List<Map<String, dynamic>> _buildHistory(
    List<Map<String, dynamic>>? history,
  ) {
    if (history == null || history.isEmpty) return [];
    return history.map((msg) {
      final isSender = msg['isSender'] as bool? ?? false;
      return {
        'role': isSender ? 'user' : 'assistant',
        'content': msg['text'] as String? ?? '',
      };
    }).toList();
  }

  /// Format conversation history for the API (called from the screen).
  static List<Map<String, dynamic>> formatConversationHistory(
    List<dynamic> messages,
  ) {
    return messages.map((message) {
      return {
        'text': message.text ?? '',
        'isSender': message.isSender ?? false,
        'timestamp':
            message.timestamp?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      };
    }).toList();
  }
}
