import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/payment_mehods/payment_methods_states.dart';

import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/payment_method_model.dart';


class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit() : super(PaymentMethodsInitial());

  Future<void> fetchPaymentMethods() async {
    final int creatorId = CacheHelper.getData(key: 'userId');
    emit(PaymentMethodsLoading());
    try {
      final response = await DioHelper.getData(url: '/api/payment-methods/$creatorId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<PaymentMethod> methods = data.map((e) => PaymentMethod.fromJson(e)).toList();
        emit(PaymentMethodsLoaded(methods));
      } else {
        emit(PaymentMethodsError('Failed to load payment methods'));
      }
    } catch (e) {
      emit(PaymentMethodsError(e.toString()));
    }
  }

  Future<void> savePaymentMethods(List<PaymentMethod> methods) async {
    emit(PaymentMethodsLoading());
    try {
      final int creatorId = CacheHelper.getData(key: 'userId');
      final response = await DioHelper.postData(
        url: '/api/payment-methods/$creatorId',
        data: {
          'methods': methods.map((e) => e.toJson()).toList(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(PaymentMethodsLoaded(methods));
      } else {
        emit(PaymentMethodsError('Failed to save payment methods'));
      }
    } catch (e) {
      emit(PaymentMethodsError(e.toString()));
    }
  }
}
