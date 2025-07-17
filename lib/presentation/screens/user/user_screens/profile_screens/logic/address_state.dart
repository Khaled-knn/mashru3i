
import 'package:equatable/equatable.dart';
import 'package:mashrou3i/data/models/user_model.dart';

abstract class UserAddressState extends Equatable {
  const UserAddressState();

  @override
  List<Object?> get props => [];
}

class UserAddressInitial extends UserAddressState {}

class UserAddressLoading extends UserAddressState {}

class UserAddressSaved extends UserAddressState {
  final UserModel address;
  const UserAddressSaved(this.address);

  @override
  List<Object?> get props => [address];
}

class UserLocationLoading extends UserAddressState {}
class UserAddressLoaded extends UserAddressState {
  final UserModel user;
  const UserAddressLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserLocationDetected extends UserAddressState {
  final String city;
  final String street;
  final String country;
  const UserLocationDetected({required this.city, required this.street, required this.country});

  @override
  List<Object?> get props => [city, street, country];
}


enum UserAddressErrorType {
  network,
  locationDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  notFound,
  general,
}

class AddressError extends UserAddressState {
  final String message;
  final UserAddressErrorType type;
  const AddressError(this.message, {this.type = UserAddressErrorType.general});

  @override
  List<Object?> get props => [message, type];
}