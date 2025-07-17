import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mashrou3i/data/models/user_model.dart';
import '../../../../../../../core/network/remote/dio.dart';
import '../../../../../../../core/theme/color.dart';
import '../../../../../../core/helper/user_data_manager.dart';
import 'address_state.dart';
class UserAddressCubit extends Cubit<UserAddressState> {
  UserAddressCubit() : super(UserAddressInitial());

  Future<void> updateUserAddress({
    String? city,
    String? street,
    String? country,
  }) async {
    emit(UserAddressLoading());
    try {
      final token = await UserDataManager.getUserToken();
      if (token == null) {
        emit(const AddressError('Authentication token not found. Please log in again.'));
        return;
      }

      final Map<String, dynamic> requestData = {};
      if (city != null) requestData['city'] = city;
      if (street != null) requestData['street'] = street;
      if (country != null) requestData['country'] = country;

      if (requestData.isEmpty) {
        emit(const AddressError('No data provided for update.'));
        return;
      }

      final response = await DioHelper.updateData(
        url: '/api/auth/profile',
        data: requestData,
        token: 'Bearer $token',
      );


      if (response.statusCode == 200) {
        final data = response.data;
        final UserModel updatedUser = UserModel.fromJson(data['user']);
        await UserDataManager.saveUserData(token: token, user: updatedUser);
        emit(UserAddressSaved(updatedUser));
      } else {
        String errorMessage = 'Failed to update address.';
        if (response.data is Map && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }
        emit(AddressError(errorMessage));
      }
    } catch (e) {
      emit(AddressError('Failed to save address: ${e.toString()}'));
    }
  }

  Future<void> fetchUserAddress() async {
    emit(UserAddressLoading());
    try {
      final UserModel? user = UserDataManager.getUserModel();
      if (user != null && (user.city != null || user.street != null || user.country != null)) {
        emit(UserAddressLoaded(user));
      } else {
        emit( AddressError('no_address_found'.tr()));
      }
    } catch (e) {
      emit(AddressError('Failed to fetch address: ${e.toString()}'.tr()));
    }
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    emit(UserLocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(AddressError(
          'location_services_disabled'.tr(),
          type: UserAddressErrorType.locationDisabled,
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(AddressError(
            'location_permission_denied'.tr(),
            type: UserAddressErrorType.permissionDenied,
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(AddressError(
          'location_permission_permanently_denied'.tr(),
          type: UserAddressErrorType.permissionPermanentlyDenied,
        ));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: context.locale.languageCode,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final String detectedStreet = _formatStreet(place);
        final String detectedCity = place.locality ?? place.subAdministrativeArea ?? '';
        final String detectedCountry = place.country ?? '';
        final String? building = place.subLocality;
        final String? floor = null;
        final String? apartment = null;

        emit(UserLocationDetected(
          city: detectedCity,
          street: detectedStreet,
          country: detectedCountry,
        ));
      } else {
        emit(AddressError('no_address_found'.tr(), type: UserAddressErrorType.notFound));
      }
    } catch (e) {
      emit(AddressError(
        'location_fetch_error'.tr(args: [e.toString()]),
        type: UserAddressErrorType.network,
      ));
    }
  }

  Future<bool> checkLocationService(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      final bool? enableService = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'location1.enable_title'.tr(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 16
            ),
          ),
          content: Text(
            'location1.enable_message'.tr(),
            style: TextStyle(fontSize: 14 , color: Colors.black),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              onPressed: () => Navigator.pop(context, false),
              child: Text('location1.cancel'.tr() , style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings , color: Colors.grey[800],),
                  SizedBox(width: 10,),
                  Text(
                    'location1.enable'.tr(),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      if (enableService == true) {
        try {
          await Geolocator.openLocationSettings();
          return await Geolocator.isLocationServiceEnabled();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('location1.open_settings_error'.tr()),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }
    }
    return serviceEnabled;
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