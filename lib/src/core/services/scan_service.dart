import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class ScanService {
  final ApiService _apiService;
  late final Dio _imageDio;

  ScanService(this._apiService) {
    _imageDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.strokeImageServiceUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
  }

  /// Upload a brain scan image to the stroke image detection service.
  Future<Map<String, dynamic>> uploadScan(File imageFile) async {
    log('ScanService: Uploading scan to ${ApiConstants.strokeImageServiceUrl}...');
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

      log('ScanService: Response: ${response.data}');

      final data = response.data as Map<String, dynamic>;

      // Model file not yet uploaded on the server — surface the message.
      if (!data.containsKey('prediction')) {
        final msg = data['message'] as String? ?? 'Model not available yet.';
        throw Exception(msg);
      }

      final prediction = data['prediction'] as String;
      final confidence = data['confidence'] as String;

      return {
        'result': prediction.toLowerCase(),
        'confidence': confidence,
        'prediction': prediction,
        'model': 'Stroke Image Detection Model',
        'source': 'AI',
      };
    } catch (e) {
      log('ScanService: Upload failed: $e');
      rethrow;
    }
  }

  /// Get scan result by ID via the main API gateway.
  Future<Map<String, dynamic>> getScanResult(int scanId) async {
    log('ScanService: Fetching scan result for ID: $scanId...');
    try {
      final response = await _apiService.get(ApiConstants.scanById(scanId.toString()));
      log('ScanService: Scan result retrieved: ${response.data}');
      return response.data;
    } catch (e) {
      log('ScanService: Failed to get scan result: $e');
      rethrow;
    }
  }

  /// Get all scans for the current user via the main API gateway.
  Future<List<Map<String, dynamic>>> getUserScans() async {
    log('ScanService: Fetching user scans...');
    try {
      final response = await _apiService.get(ApiConstants.scans);
      log('ScanService: User scans retrieved');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      log('ScanService: Failed to get user scans: $e');
      rethrow;
    }
  }
}
