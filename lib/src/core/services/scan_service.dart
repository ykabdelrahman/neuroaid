import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ScanService {
  late final Dio _imageDio;
  late final Dio _faceDio;
  late final Dio _handDio;

  ScanService() {
    _imageDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.strokeImageServiceUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    _faceDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.strokeFaceServiceUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    _handDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.strokeHandServiceUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
  }

  /// Upload a brain scan image to the stroke image detection service.
  Future<Map<String, dynamic>> uploadScan(File imageFile) async {
    log('🧠 ScanService: Uploading brain scan to ${ApiConstants.strokeImageServiceUrl}...');
    try {
      final bytes = await imageFile.readAsBytes();
      log('ScanService: Image size: ${bytes.length} bytes');

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _imageDio.post(
        ApiConstants.strokeImagePredict,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      log('ScanService: Brain scan response: ${response.data}');
      final data = response.data as Map<String, dynamic>;

      // API response: { result, risk_category, stroke_probability, filename, status }
      if (!data.containsKey('result')) {
        final msg = data['message'] as String? ?? 'Unexpected response from brain scan service.';
        throw Exception(msg);
      }

      final resultText = data['result'] as String? ?? 'Unknown';
      final riskCategory = data['risk_category'] as String? ?? '';
      final strokeProbability = data['stroke_probability'];

      // Normalize to STROKE / NORMAL for the result dialog
      final isStroke = resultText.toLowerCase().contains('stroke');
      final normalized = isStroke ? 'STROKE' : 'NORMAL';

      double confidence = 0;
      if (strokeProbability is int) {
        confidence = strokeProbability.toDouble();
      } else if (strokeProbability is double) {
        confidence = strokeProbability;
      } else if (strokeProbability is String) {
        confidence = double.tryParse(strokeProbability) ?? 0;
      }

      log('✅ ScanService: Brain result=$normalized risk=$riskCategory prob=$confidence%');
      return {
        'result': normalized,
        'confidence': confidence,
        'risk_category': riskCategory,
        'stroke_probability': strokeProbability,
        'raw_result': resultText,
        'model': 'Stroke Image Detection Model',
        'source': 'AI',
      };
    } catch (e) {
      log('❌ ScanService: Brain scan failed: $e');
      rethrow;
    }
  }

  /// Upload a face image to the face stroke detection service.
  Future<Map<String, dynamic>> uploadFaceScan(File imageFile) async {
    log('ScanService: Uploading face scan to ${ApiConstants.strokeFaceServiceUrl}...');
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _faceDio.post(
        ApiConstants.strokeFacePredict,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      log('ScanService: Face response: ${response.data}');
      final data = response.data as Map<String, dynamic>;

      return {
        'result': (data['result'] as String? ?? 'UNKNOWN').toUpperCase(),
        'confidence': data['confidence'],
        'issues': data['issues'] ?? [],
        'reason': data['reason'] ?? '',
        'stroke_score': data['stroke_score'] ?? 0,
        'metrics': data['metrics'] ?? {},
        'model': 'Face Stroke Detection Model',
        'source': 'AI',
        'scan_type': 'face',
      };
    } on DioException catch (e) {
      final msg = _extractApiError(e) ?? 'Face scan failed. Please try again.';
      log('ScanService: Face upload failed: $msg');
      throw Exception(msg);
    } catch (e) {
      log('ScanService: Face upload failed: $e');
      rethrow;
    }
  }

  /// Upload a hand image to the hand stroke detection service.
  Future<Map<String, dynamic>> uploadHandScan(File imageFile) async {
    log('ScanService: Uploading hand scan to ${ApiConstants.strokeHandServiceUrl}...');
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _handDio.post(
        ApiConstants.strokeHandPredict,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      log('ScanService: Hand response: ${response.data}');
      final data = response.data as Map<String, dynamic>;

      return {
        'result': (data['result'] as String? ?? 'UNKNOWN').toUpperCase(),
        'confidence': data['confidence'],
        'issues': data['issues'] ?? [],
        'left_fingers': data['left_fingers'] ?? 0,
        'right_fingers': data['right_fingers'] ?? 0,
        'finger_diff': data['finger_diff'] ?? 0,
        'stroke_score': data['stroke_score'] ?? 0,
        'left_is_open': data['left_is_open'] ?? false,
        'right_is_open': data['right_is_open'] ?? false,
        'model': 'Hand Stroke Detection Model',
        'source': 'AI',
        'scan_type': 'hand',
      };
    } on DioException catch (e) {
      final msg = _extractApiError(e) ?? 'Hand scan failed. Please try again.';
      log('ScanService: Hand upload failed: $msg');
      throw Exception(msg);
    } catch (e) {
      log('ScanService: Hand upload failed: $e');
      rethrow;
    }
  }

  String? _extractApiError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['error'] as String? ?? data['message'] as String?;
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> getScanResult(String scanId) async => {};
  Future<List<Map<String, dynamic>>> getUserScans() async => [];
}
