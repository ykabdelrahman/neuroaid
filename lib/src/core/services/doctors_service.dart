import 'dart:developer';

import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:neuroaid/src/core/constants/api_constants.dart';
import 'package:neuroaid/src/core/services/api_service.dart';

class DoctorsService {
  final ApiService _apiService;

  DoctorsService(this._apiService);

  Future<List<DoctorModel>> getDoctors() async {
    try {
      log('DoctorsService: Fetching doctors via gateway...');
      final response = await _apiService.get(
        ApiConstants.doctors, // Updated to use gateway route: /api/main/doctors
      );

      log('DoctorsService: Response received. Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        log('DoctorsService: Parsing ${data.length} doctors');
        return data.map((json) => DoctorModel.fromJson(json)).toList();
      } else {
        log(
          'DoctorsService: Failed to fetch doctors. Status: ${response.statusCode}',
        );
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      log('DoctorsService: Error fetching doctors: $e');
      rethrow;
    }
  }

  // Get favorites for a user via API Gateway
  Future<List<DoctorModel>> getFavorites(int userId) async {
    try {
      log('DoctorsService: Fetching favorites for user $userId via gateway...');
      // Get favorites relations
      final response = await _apiService.get(
        '${ApiConstants.favorites}?userId=$userId', // Updated: /api/main/favorites
      );

      if (response.statusCode == 200) {
        // Extract the 'favorites' array from the response
        final List<dynamic> favoritesData =
            response.data['favorites'] ?? response.data;
        if (favoritesData.isEmpty) return [];

        // The backend now returns doctor info embedded in each favorite
        // So we can extract doctors directly from favorites
        final List<DoctorModel> favoriteDoctors = [];

        for (var favorite in favoritesData) {
          if (favorite['doctor'] != null) {
            // Create a DoctorModel from the embedded doctor info
            final doctorJson = favorite['doctor'] as Map<String, dynamic>;
            // Add the doctorId to the doctor object
            doctorJson['id'] = favorite['doctorId'];

            // Add default fields if missing
            doctorJson['rating'] = doctorJson['rating'] ?? 0.0;
            doctorJson['reviews'] = doctorJson['reviews'] ?? 0;
            doctorJson['experience'] = doctorJson['experience'] ?? '';
            doctorJson['available'] = doctorJson['available'] ?? true;
            doctorJson['distance'] = doctorJson['distance'] ?? '';
            doctorJson['nextAvailable'] = doctorJson['nextAvailable'] ?? '';

            favoriteDoctors.add(DoctorModel.fromJson(doctorJson));
          }
        }

        return favoriteDoctors;
      }
      return [];
    } catch (e) {
      log('DoctorsService: Error fetching favorites: $e');
      return [];
    }
  }

  // Add to favorites via API Gateway
  Future<void> addToFavorites(int userId, int doctorId) async {
    try {
      log('DoctorsService: Adding to favorites via gateway...');
      await _apiService.post(
        ApiConstants
            .favorites, // Updated to use gateway route: /api/main/favorites
        data: {'userId': userId, 'doctorId': doctorId},
      );
      log('DoctorsService: Added to favorites successfully');
    } catch (e) {
      log('DoctorsService: Error adding favorite: $e');
      rethrow;
    }
  }

  // Remove from favorites via API Gateway
  Future<void> removeFromFavorites(int userId, int doctorId) async {
    try {
      log('DoctorsService: Removing from favorites via gateway...');
      // The backend accepts doctorId directly in the DELETE endpoint
      await _apiService.delete(
        ApiConstants.favoriteById(
          doctorId.toString(),
        ), // Updated: /api/main/favorites/{id}
      );
      log('DoctorsService: Removed from favorites successfully');
    } catch (e) {
      log('DoctorsService: Error removing favorite: $e');
      rethrow;
    }
  }
}
