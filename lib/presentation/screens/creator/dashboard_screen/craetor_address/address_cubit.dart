import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../data/models/creator_address.dart';
import 'address_service.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressService _addressService;
  final int? creatorId;
  final String token;

  AddressCubit({
    required this.creatorId,
    required this.token,
    AddressService? addressService,
  })  : _addressService = addressService ?? AddressService(),
        super(const AddressInitial()) {
    if (creatorId != null) {
      loadAddress();
    }
  }

  Future<void> loadAddress() async {
    if (creatorId == null) return;

    emit(const AddressLoading());
    try {
      final address = await _addressService.getAddress(creatorId!, token);
      if (address != null) {
        emit(AddressLoaded(address));
      } else {
        emit(AddressError('address_not_found'.tr(), type: ErrorType.notFound));
      }
    } catch (e) {
      emit(AddressError(
        'load_address_error'.tr(args: [e.toString()]),
        type: ErrorType.network,
      ));
    }
  }

  Future<void> saveAddress(AddressModel address) async {
    emit(const AddressLoading());
    try {
      final success = await _addressService.upsertAddress(address, token);
      if (success) {
        emit(AddressSaved(address));
        await loadAddress();
      } else {
        emit(AddressError('save_address_failed'.tr()));
      }
    } catch (e) {
      emit(AddressError(
        'save_address_error'.tr(args: [e.toString()]),
        type: ErrorType.network,
      ));
    }
  }

  Future<void> getCurrentLocation() async {
    emit(const LocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(AddressError(
          'location_services_disabled'.tr(),
          type: ErrorType.locationDisabled,
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(AddressError(
            'location_permission_denied'.tr(),
            type: ErrorType.permissionDenied,
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(AddressError(
          'location_permission_permanently_denied'.tr(),
          type: ErrorType.permissionPermanentlyDenied,
        ));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final address = AddressModel(
          creatorId: creatorId,
          street: _formatStreet(place),
          city: place.locality ?? place.subAdministrativeArea ?? '',
          country: place.country ?? '',
        );
        emit(LocationDetected(address));
      } else {
        emit(AddressError('no_address_found'.tr(), type: ErrorType.notFound));
      }
    } catch (e) {
      emit(AddressError(
        'location_fetch_error'.tr(args: [e.toString()]),
        type: ErrorType.network,
      ));
    }
  }

  String _formatStreet(Placemark place) {
    final parts = [
      place.street,
      place.thoroughfare,
      place.subThoroughfare,
    ].where((part) => part?.isNotEmpty ?? false);
    return parts.join(', ');
  }
}