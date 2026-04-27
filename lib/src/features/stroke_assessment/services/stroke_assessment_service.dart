import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:neuroaid/src/core/constants/api_constants.dart';
import '../models/stroke_assessment_request.dart';
import '../models/stroke_assessment_response.dart';
import '../models/detailed_stroke_assessment_request.dart';

class StrokeAssessmentService {
  late final Dio _dio;

  StrokeAssessmentService([_]) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.strokeQaServiceUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// Submit the quick 9-question assessment.
  ///
  /// The deployed backend expects the detailed medical format, so this will
  /// fail with a validation error until the quick assessment is mapped to
  /// the detailed fields. Kept for backward compatibility with the cubit flow.
  Future<StrokeAssessmentResponse> submitAssessment(
    StrokeAssessmentRequest request,
  ) async {
    try {
      log('📤 Submitting quick stroke assessment...');
      final response = await _dio.post(
        ApiConstants.strokeQaPredict,
        data: request.toJson(),
      );
      log('✅ Quick assessment response: ${response.data}');
      return StrokeAssessmentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      log('❌ DioException during quick assessment: ${e.message}');
      log('❌ Response: ${e.response?.data}');
      throw Exception(
        'Failed to complete assessment. Please check your connection and try again.',
      );
    } catch (e) {
      log('❌ Unexpected error during quick assessment: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Submit the detailed medical stroke risk assessment.
  ///
  /// Payload matches the deployed `/predict` endpoint exactly.
  Future<StrokeAssessmentResponse> submitDetailedAssessment(
    DetailedStrokeAssessmentRequest request,
  ) async {
    try {
      log('📤 Submitting detailed stroke assessment...');
      log('📦 Payload: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.strokeQaPredict,
        data: request.toJson(),
      );

      log('✅ Detailed assessment response: ${response.data}');
      return StrokeAssessmentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      log('❌ DioException during detailed assessment: ${e.message}');
      log('❌ Response: ${e.response?.data}');
      throw Exception(
        'Failed to complete assessment. Please check your connection and try again.',
      );
    } catch (e) {
      log('❌ Unexpected error during detailed assessment: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
