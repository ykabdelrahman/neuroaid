import 'dart:developer';
import 'package:neuroaid/src/core/constants/api_constants.dart';
import 'package:neuroaid/src/core/services/api_service.dart';

class FaqService {
  final ApiService _apiService;

  FaqService(this._apiService);

  /// Get all FAQs via API Gateway
  Future<List<Map<String, dynamic>>> getFaqs() async {
    log('FaqService: Fetching FAQs via gateway...');
    try {
      final response = await _apiService.get(
        ApiConstants.faqs, // Updated to use gateway route: /api/main/faqs
      );
      log('FaqService: FAQs retrieved successfully');

      // Handle nested structure: {faqs: {faqs: [...]}}
      var data = response.data;

      // If data is a Map with 'faqs' key, extract it
      if (data is Map<String, dynamic> && data.containsKey('faqs')) {
        data = data['faqs'];

        // If it's still a Map with 'faqs' key (double nested), extract again
        if (data is Map<String, dynamic> && data.containsKey('faqs')) {
          data = data['faqs'];
        }
      }

      // Now data should be a List
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      log('FaqService: Unexpected data format');
      return [];
    } catch (e) {
      log('FaqService: Error fetching FAQs: $e');
      rethrow;
    }
  }

  /// Get FAQ by ID via API Gateway
  Future<Map<String, dynamic>> getFaqById(int id) async {
    log('FaqService: Fetching FAQ with ID: $id via gateway...');
    try {
      final response = await _apiService.get(
        ApiConstants.faqById(id.toString()), // Updated: /api/main/faqs/{id}
      );
      log('FaqService: FAQ retrieved successfully');
      return response.data;
    } catch (e) {
      log('FaqService: Error fetching FAQ: $e');
      rethrow;
    }
  }
}
