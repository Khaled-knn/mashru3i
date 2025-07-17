import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/availability_model.dart';
import 'availability_state.dart';

class AvailabilityCubit extends Cubit<AvailabilityState> {
  AvailabilityCubit() : super(AvailabilityInitial());

  Future<void> fetchAvailability() async {
    final int creatorId = CacheHelper.getData(key: 'userId');
    emit(AvailabilityLoading());
    try {
      final response = await DioHelper.getData(url: '/api/availability/$creatorId');
      if (response.statusCode == 200) {
        final data = response.data;
        final availability = Availability.fromJson(data);
        emit(AvailabilityLoaded(availability));
      } else {
        emit(AvailabilityError('Failed to load availability'));
      }
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> saveAvailability(Availability availability) async {
    emit(AvailabilityLoading());
    try {
      final int creatorId = CacheHelper.getData(key: 'userId');
      final response = await DioHelper.postData(
        url: '/api/availability/$creatorId',
        data: availability.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AvailabilityLoaded(availability));
      } else {
        emit(AvailabilityError('Failed to save availability'));
      }
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }
}