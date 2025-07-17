import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import 'creator_register_state.dart';

class CreatorRegisterCubit extends Cubit<CreatorRegisterState> {
  CreatorRegisterCubit() : super(CreatorRegisterInitial());
  static CreatorRegisterCubit get(context) => BlocProvider.of(context);

  Future<void> postRegisterData({
    required professionId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String storeName,
    required String password,
    required confirmPassword ,
  }) async {
    if (password != confirmPassword) {
      emit(CreatorRegisterError('كلمات المرور غير متطابقة'));
      return;
    }

    emit(CreatorRegisterLoading());


    DioHelper.postData(
      url: CREATORREGISTER,
      data: {
        "profession_id": professionId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "store_name": storeName,
        "password": password,
      },
    ).then((value) async {
      print(value.data);
      final token = value.data['token'];
      final int? userId = value.data['id'];
      if (userId != null) {
        await CacheHelper.saveData(key: 'userId', value: userId);
      }
      await CacheHelper.saveData(key: 'token', value: token);
      emit(CreatorRegisterSuccess(
          token: token,
          creatorId: userId
      ));
    }).catchError((error) {
      String errorMessage = 'حدث خطأ';

      if (error is DioException) {
        final response = error.response;
        if (response != null && response.data != null) {
          errorMessage = response.data['error'] ?? 'خطأ في الخادم';
        } else {
          errorMessage = error.message ?? 'لا يمكن الاتصال بالخادم';
        }
      } else {
        errorMessage = error.toString();
      }

      emit(CreatorRegisterError(errorMessage));
      print(errorMessage);
    });
  }


  bool isPasswordShow = true;

  void changeVisibilityIcon() {
    isPasswordShow = !isPasswordShow;
    emit(ChangeVisibilityIconState());
  }

  bool isPasswordConfirmShow = true;
  void changeConfirmVisibilityIcon() {
    isPasswordConfirmShow = !isPasswordConfirmShow;
    emit(changeConfirmVisibilityIconState());
  }

}
