import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/booking/booking_state.dart';
import 'package:neuroaid/src/core/models/booking_model.dart';
import 'package:neuroaid/src/core/services/booking_service.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;

  BookingCubit(this._bookingService) : super(BookingInitial());

  Future<void> loadBookings(String userId) async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingService.getBookings(userId);
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    emit(BookingLoading());
    try {
      await _bookingService.createBooking(booking);
      emit(const BookingSuccess('Booking created successfully'));
      await loadBookings(booking.userId);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    // We don't want to emit loading here if we want to keep the list visible
    // But for simplicity, let's emit loading or handle it optimistically
    try {
      await _bookingService.cancelBooking(bookingId);
      // Reload bookings
      await loadBookings(userId);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
