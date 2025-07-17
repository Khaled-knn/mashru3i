import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/screens/user/register/logic/user_register_states.dart';
import '../../../../../core/helper/user_data_manager.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/user_model.dart';


class UserRegisterCubit extends Cubit<UserRegisterState> {
  UserRegisterCubit() : super(UserRegisterInitial());
  static UserRegisterCubit get(context) => BlocProvider.of(context);

  Future<void> postRegisterData({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String confirmPassword,
  }) async {
    emit(UserRegisterLoading());

    if (password != confirmPassword) {
      emit(UserRegisterError('Passwords do not match'));
      return;
    }

    try {
      final response = await DioHelper.postData(
        url: USERREGISTER,
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
          "phone": phone,
        },
      );
      final data = response.data;
      print(data);
      final user = data['user'];
      final userToken = data['token'];
      print('$userToken ========================');
      final int? userId = data['user']['id'];
      print('$userId ===user=====================');
      if (userId != null) {
        await CacheHelper.saveData(key: 'userIdTwo', value: userId);
      }
      final userRegister = UserModel.fromJson(data['user']);
      final token = data['token'];
      await CacheHelper.saveData(key: 'userToken', value: userToken);
      await UserDataManager.saveUserData(token: token, user: userRegister);
      emit(UserRegisterSuccess(token: token, userId: userRegister.id));    }
    catch (error) {
      String errorMessage = 'Error';
      if (error is DioException) {
        final response = error.response;
        if (response != null && response.data != null) {
          print("Dio error response: ${response.data}");
          errorMessage = response.data['message'] ?? '${response.data['message']}';
        } else {
          errorMessage = error.message ?? 'Cannot connect to server';
        }
      } else {
        errorMessage = error.toString();
      }
      emit(UserRegisterError(errorMessage));
      print("$errorMessage");
    }
  }

  bool isPasswordShow = true;

  void changeVisibilityIcon() {
    isPasswordShow = !isPasswordShow;
    emit(UserChangeVisibilityIconState());
  }

  bool isPasswordConfirmShow = true;

  void changeConfirmVisibilityIcon() {
    isPasswordConfirmShow = !isPasswordConfirmShow;
    emit(UserChangeConfirmVisibilityIconState());
  }
}




















