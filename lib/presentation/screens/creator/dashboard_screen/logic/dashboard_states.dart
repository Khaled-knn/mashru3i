import '../../../../../data/models/creator_profile_model.dart';

abstract class DashBoardStates {}
class DashBoardInitialState extends DashBoardStates {}
class DashboardChangeBottomNavState extends DashBoardStates {}
class ProfileLoading extends DashBoardStates {}

class ProfileLoaded extends DashBoardStates {
  final CreatorProfile profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends DashBoardStates {
  final String error;

  ProfileError(this.error);
}

class UpdatingStoreNameLoading extends DashBoardStates {}
class UpdateStoreNameLoaded extends DashBoardStates {
  final CreatorProfile profile;

  UpdateStoreNameLoaded(this.profile);
}
class UpdateStoreNameError extends DashBoardStates {
  final String error;
  UpdateStoreNameError(this.error);
}
class LogoutLoadingState extends DashBoardStates {}

class LoggedOutState extends DashBoardStates {}

class LogoutErrorState extends DashBoardStates {
  final String message;
  LogoutErrorState(this.message);
}
class UpdateProfileImageLoading extends DashBoardStates {}

class UpdateProfileImageSuccess extends DashBoardStates {}

class UpdateProfileImageError extends DashBoardStates {
  final String message;
  UpdateProfileImageError(this.message);
}


// ----- Update Creator Profile -----
class UpdateCreatorProfileLoading extends DashBoardStates {}

class UpdateCreatorProfileSuccess extends DashBoardStates {
  final CreatorProfile profile;
  UpdateCreatorProfileSuccess(this.profile);
}

class UpdateCreatorProfileError extends DashBoardStates {
  final String message;

  UpdateCreatorProfileError(this.message);
}
class UpdateDeliveryValueSuccess extends DashBoardStates {
  final double newValue;

  UpdateDeliveryValueSuccess(this.newValue);
}


class getProfileImagePickedSuccess extends DashBoardStates {}
class getProfileImagePickedError extends DashBoardStates {}
class getCoverImagePickedSuccess extends DashBoardStates {}
class getCoverImagePickedError extends DashBoardStates {}
class AppUploadProfileImageLoading extends DashBoardStates {}
class AppUploadProfileImageSuccess extends DashBoardStates {}
class AppUploadProfileImageError extends DashBoardStates {}
class AppUploadCoverImageLoading extends DashBoardStates {}
class AppUploadCoverImageSuccess extends DashBoardStates {}
class AppUploadCoverImageError extends DashBoardStates {}
class ToggleImageButtonsState extends DashBoardStates {}


class RequestTokensLoadingState extends DashBoardStates {}

class RequestTokensSuccessState extends DashBoardStates {
  final String message;
  RequestTokensSuccessState(this.message);
}

class RequestTokensErrorState extends DashBoardStates {
  final String error;
  RequestTokensErrorState(this.error);
}

