import 'dart:developer';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/core/constants/api_constants.dart';
import 'package:neuroaid/src/core/services/api_service.dart';

class BookingService {
  final ApiService _apiService;

  BookingService(this._apiService);

  // Get bookings for a user via API Gateway
  Future<List<BookingModel>> getBookings(int userId) async {
    try {
      log('BookingService: Fetching bookings for user $userId via gateway...');
      final response = await _apiService.get(
        '${ApiConstants.bookings}?userId=$userId', // Updated: /api/main/bookings
      );

      if (response.statusCode == 200) {
        // Extract the 'bookings' array from the response
        final List<dynamic> data = response.data['bookings'] ?? response.data;
        log('BookingService: Found ${data.length} bookings');
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      log('BookingService: Error fetching bookings: $e');
      rethrow;
    }
  }

  // Create a new booking via API Gateway
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      log('BookingService: Creating booking via gateway...');
      // Remove ID for creation as it's auto-generated
      final Map<String, dynamic> data = booking.toJson();
      data.remove('id');

      final response = await _apiService.post(
        ApiConstants
            .bookings, // Updated to use gateway route: /api/main/bookings
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('BookingService: Booking created successfully');
        // Extract the 'booking' object from the response
        final bookingData = response.data['booking'] ?? response.data;
        return BookingModel.fromJson(bookingData);
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      log('BookingService: Error creating booking: $e');
      rethrow;
    }
  }

  // Cancel a booking via API Gateway
  Future<void> cancelBooking(int bookingId) async {
    try {
      log('BookingService: Canceling booking $bookingId via gateway...');
      // We can either delete it or update status to 'canceled'
      // Updating status is better for history
      await _apiService.patch(
        ApiConstants.bookingById(
          bookingId.toString(),
        ), // Updated: /api/main/bookings/{id}
        data: {'status': 'canceled'},
      );
      log('BookingService: Booking canceled successfully');
    } catch (e) {
      log('BookingService: Error canceling booking: $e');
      rethrow;
    }
  }
}
