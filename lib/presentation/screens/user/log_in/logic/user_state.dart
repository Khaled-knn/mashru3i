import '../../../../../data/models/user_model.dart';

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}
class UserLoginChangeVisibilityIconState extends LoginState {}

class LoginSuccessState extends LoginState {
  final dynamic responseData;
  LoginSuccessState(this.responseData);
}

class LoginErrorState extends LoginState {
  final String error;
  LoginErrorState(this.error);
}


class ChangePasswordLoadingState extends LoginState {}
class ChangePasswordSuccessState extends LoginState {
  final String message;
  ChangePasswordSuccessState(this.message);
}
class ChangePasswordErrorState extends LoginState {
  final String error;
  ChangePasswordErrorState(this.error);
}


class UserForgotPasswordLoading extends LoginState {}
class UserForgotPasswordSuccess extends LoginState {
  final String message;
  UserForgotPasswordSuccess({required this.message});
}
class UserForgotPasswordError extends LoginState {
  final String error;
  UserForgotPasswordError(this.error);
}



class UpdateProfileLoadingState extends LoginState {}
class UpdateProfileSuccessState extends LoginState {
  final UserModel updatedUser;
  final String message;
  UpdateProfileSuccessState({required this.updatedUser, required this.message});
}
class UpdateProfileErrorState extends LoginState {
  final String error;
  UpdateProfileErrorState(this.error);
}