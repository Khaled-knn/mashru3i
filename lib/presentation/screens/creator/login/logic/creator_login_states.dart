abstract class CreatorLoginState {}

class CreatorLoginInitialState extends CreatorLoginState {}

class LoginChangeVisibilityIconState extends CreatorLoginState {}

class CreatorLoginLoadingState extends CreatorLoginState {}

class CreatorLoginSuccessState extends CreatorLoginState {
  final dynamic responseData;
  CreatorLoginSuccessState(this.responseData);
}

class CreatorLoginErrorState extends CreatorLoginState {
  final String error;
  CreatorLoginErrorState(this.error);
}



