import 'package:equatable/equatable.dart';
import 'package:neuroaid/src/core/models/doctor_model.dart';

abstract class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object> get props => [];
}

class DoctorsInitial extends DoctorsState {}

class DoctorsLoading extends DoctorsState {}

class DoctorsLoaded extends DoctorsState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> favorites;

  const DoctorsLoaded(this.doctors, {this.favorites = const []});

  @override
  List<Object> get props => [doctors, favorites];

  DoctorsLoaded copyWith({
    List<DoctorModel>? doctors,
    List<DoctorModel>? favorites,
  }) {
    return DoctorsLoaded(
      doctors ?? this.doctors,
      favorites: favorites ?? this.favorites,
    );
  }
}

class DoctorsError extends DoctorsState {
  final String message;

  const DoctorsError(this.message);

  @override
  List<Object> get props => [message];
}
