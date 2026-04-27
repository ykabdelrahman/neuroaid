import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroaid/src/core/bloc/doctors/doctors_state.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';
import 'package:neuroaid/src/core/services/doctors_service.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsService _doctorsService;

  DoctorsCubit(this._doctorsService) : super(DoctorsInitial());

  Future<void> loadDoctors() async {
    emit(DoctorsLoading());
    log('DoctorsCubit: Loading doctors...');
    try {
      final doctors = await _doctorsService.getDoctors();
      log('DoctorsCubit: Loaded ${doctors.length} doctors');
      emit(DoctorsLoaded(doctors));
    } catch (e) {
      log('DoctorsCubit: Error loading doctors: $e');
      emit(DoctorsError(e.toString()));
    }
  }

  Future<void> loadFavorites(int userId) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      try {
        final favorites = await _doctorsService.getFavorites(userId);
        emit(currentState.copyWith(favorites: favorites));
      } catch (e) {
        log('DoctorsCubit: Error loading favorites: $e');
      }
    }
  }

  Future<void> toggleFavorite(int userId, DoctorModel doctor) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final isFavorite = currentState.favorites.any((d) => d.id == doctor.id);

      // Optimistic update
      List<DoctorModel> newFavorites;
      if (isFavorite) {
        newFavorites = currentState.favorites
            .where((d) => d.id != doctor.id)
            .toList();
      } else {
        newFavorites = [...currentState.favorites, doctor];
      }
      emit(currentState.copyWith(favorites: newFavorites));

      try {
        if (isFavorite) {
          await _doctorsService.removeFromFavorites(userId, doctor.id);
        } else {
          await _doctorsService.addToFavorites(userId, doctor.id);
        }
      } catch (e) {
        // Revert on error
        emit(currentState);
        log('DoctorsCubit: Error toggling favorite: $e');
      }
    }
  }
}
