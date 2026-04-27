import 'dart:developer';

import 'package:appwrite/appwrite.dart';

import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import 'appwrite_service.dart';

class BookingService {
  final AppwriteService _appwrite;

  BookingService(this._appwrite);

  Future<List<BookingModel>> getBookings(String userId) async {
    log('BookingService: Fetching bookings for $userId');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.bookingsCollection,
        queries: [Query.equal('userId', userId)],
      );

      final bookings = <BookingModel>[];
      for (final doc in result.documents) {
        final data = Map<String, dynamic>.from(doc.data);
        data['\$id'] = doc.$id;

        // Enrich with doctor info
        final doctorId = data['doctorId'] as String? ?? '';
        if (doctorId.isNotEmpty && (data['doctorName'] == null || (data['doctorName'] as String).isEmpty)) {
          try {
            final doctorDoc = await _appwrite.databases.getDocument(
              databaseId: AppwriteService.databaseId,
              collectionId: AppwriteService.doctorsCollection,
              documentId: doctorId,
            );
            final doctor = DoctorModel.fromJson(doctorDoc.data..addAll({'\$id': doctorDoc.$id}));
            data['doctorName'] = doctor.name;
            data['doctorSpecialty'] = doctor.specialty;
          } catch (_) {}
        }

        bookings.add(BookingModel.fromJson(data));
      }
      return bookings;
    } on AppwriteException catch (e) {
      log('BookingService: Error: ${e.message}');
      throw Exception(e.message ?? 'Failed to load bookings');
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    log('BookingService: Creating booking for user ${booking.userId}');
    try {
      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.bookingsCollection,
        documentId: ID.unique(),
        data: {
          'userId': booking.userId,
          'doctorId': booking.doctorId,
          'date': booking.date.toIso8601String(),
          'time': booking.time,
          'status': booking.status,
          if (booking.notes != null) 'notes': booking.notes,
        },
      );

      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id;
      data['doctorName'] = booking.doctorName;
      data['doctorSpecialty'] = booking.doctorSpecialty;

      return BookingModel.fromJson(data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to create booking');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    log('BookingService: Canceling booking $bookingId');
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.bookingsCollection,
        documentId: bookingId,
        data: {'status': 'canceled'},
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to cancel booking');
    }
  }
}
