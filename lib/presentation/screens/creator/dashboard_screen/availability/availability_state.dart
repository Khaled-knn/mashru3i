import '../../../../../data/models/availability_model.dart';

abstract class AvailabilityState {}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final Availability availability;

  AvailabilityLoaded(this.availability);
}

class AvailabilityError extends AvailabilityState {
  final String message;

  AvailabilityError(this.message);
}