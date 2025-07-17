import '../../../../../data/models/creator_address.dart';

abstract class AddressState {
  const AddressState();
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final AddressModel address;
  const AddressLoaded(this.address);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AddressLoaded &&
              runtimeType == other.runtimeType &&
              address == other.address;

  @override
  int get hashCode => address.hashCode;
}

class AddressSaved extends AddressState {
  final AddressModel? address;
  const AddressSaved([this.address]);
}

class LocationLoading extends AddressState {
  const LocationLoading();
}

class LocationDetected extends AddressState {
  final AddressModel address;
  const LocationDetected(this.address);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocationDetected &&
              runtimeType == other.runtimeType &&
              address == other.address;

  @override
  int get hashCode => address.hashCode;
}

class AddressError extends AddressState {
  final String message;
  final ErrorType type;

  const AddressError(this.message, {this.type = ErrorType.general});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AddressError &&
              runtimeType == other.runtimeType &&
              message == other.message &&
              type == other.type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;
}

enum ErrorType {
  general,
  locationDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  notFound,
  network,
}