import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import 'creator_login_states.dart';

class CreatorLoginCubit extends Cubit<CreatorLoginState> {
  CreatorLoginCubit() : super(CreatorLoginInitialState());

  static CreatorLoginCubit get(context) => BlocProvider.of(context);


  void creatorLogin({required String email, required String password}) {
    emit(CreatorLoginLoadingState());

    DioHelper.postData(
      url: CREATORLOGIN,
      data: {
        'email': email,
        'password': password,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        emit(CreatorLoginSuccessState(response.data));
        final String token = response.data["token"];
        CacheHelper.saveData(key: 'token', value: token);
        CacheHelper.saveData(key: 'userId', value: response.data['id']);
        print("$token=====================================");
        print(response.data);
      } else {
        String errorMessage = response.data['error'] ?? 'Invalid credentials';
        emit(CreatorLoginErrorState(errorMessage));
      }
    }).catchError((error) {
      String errorMessage = error.response?.data['error'] ?? error.toString();
      emit(CreatorLoginErrorState(errorMessage));
    });
  }



  bool isPasswordShow = true;

  void changeVisibilityIcon() {
    isPasswordShow = !isPasswordShow;
    emit(LoginChangeVisibilityIconState());
  }
}
