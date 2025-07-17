import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../../../../../core/helper/user_data_manager.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/user_model.dart';
import 'user_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  void userLogin(String email, String password) {
    emit(LoginLoadingState());

    DioHelper.postData(
      url: '/api/auth/login/user',
      data: {'email': email, 'password': password},
    ).then((response) async {
      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel.fromJson(data['user']);
        final token = data['token'];
        final int? userId = data['user']['id'];
        print('$userId ===user=====================');
        if (userId != null) {
          await CacheHelper.saveData(key: 'userIdTwo', value: userId);
        }
        await CacheHelper.saveData(key: 'userToken', value: token);
        print(token);
        await UserDataManager.saveUserData(token: token, user: user);
        emit(LoginSuccessState(data));
      } else {

        emit(LoginErrorState("Invalid credentials"));
      }
    }).catchError((error) {
      String errorMessage = 'Error';
      if (error is DioException) {
        final response = error.response;
        if (response != null && response.data != null) {
          errorMessage = response.data['message'] ?? 'Login failed. Please try again.';
        } else {
          errorMessage = error.message ?? 'Cannot connect to server. Check your internet connection.';
        }
      } else {
        errorMessage = error.toString();
      }
      emit(LoginErrorState(errorMessage));
    });
  }

  bool isPasswordShow = true;

  void changeVisibilityIcon() {
    isPasswordShow = !isPasswordShow;
    emit(UserLoginChangeVisibilityIconState());
  }

  Future<void> signInWithGoogle() async {
    emit(LoginLoadingState());

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(LoginErrorState('Google Sign-In cancelled.'));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        print("ID Token to send to backend: $idToken");

        try {
          final response = await DioHelper.postData(
            url: '/api/auth/google-signin',
            data: {'idToken': idToken},
          );

          if (response.statusCode == 200) {
            final data = response.data;
            final String? backendToken = data['token'];
            final Map<String, dynamic>? userData = data['user'];

            print("Backend Token received: $backendToken");
            print("User Data from Backend: $userData");
            final user = UserModel.fromJson(data['user']);
            final token = data['token'];
            print(data);
            emit(LoginSuccessState(data));
            await UserDataManager.saveUserData(token: token, user: user);

            if (backendToken != null && userData != null) {
              final user = UserModel.fromJson(userData);
              final int? userId = userData['id'];
              if (userId != null) {
                await CacheHelper.saveData(key: 'userIdTwo', value: userId);
              }
              await CacheHelper.saveData(key: 'userToken', value: backendToken);
              await UserDataManager.saveUserData(token: backendToken, user: user);
              emit(LoginSuccessState(data));
            } else {
              emit(LoginErrorState('Failed to retrieve token or user data from backend.'));
            }
          } else {
            final errorMessage = response.data['message'] ?? 'Failed to sign in with Google: ${response.statusMessage}';
            emit(LoginErrorState(errorMessage));
          }
        } on DioException catch (e) {
          String errorMessage = 'Error sending ID Token to backend.';
          if (e.response != null && e.response!.data != null) {
            errorMessage = e.response!.data['message'] ?? e.response!.statusMessage ?? errorMessage;
          } else {
            errorMessage = e.message ?? 'Network error. Check your connection.';
          }
          print("Dio Error during Google Sign-In: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}");
          emit(LoginErrorState(errorMessage));
        } catch (e) {
          print("General Error sending ID Token to backend or processing backend response: $e");
          emit(LoginErrorState('An unexpected error occurred during Google sign-in.'));
        }
      } else {
        emit(LoginErrorState('Failed to get ID Token from Firebase.'));
      }
    } catch (e) {
      print("Error during Google Sign-In (Flutter side): $e");
      emit(LoginErrorState('Google Sign-In failed: ${e.toString()}'));
    }
  }



  Future<void> changeUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoadingState());

    try {
      final token = await CacheHelper.getData(key: 'userToken');
      if (token == null) {
        emit(ChangePasswordErrorState('Authentication token not found. Please log in again.'));
        return;
      }

      final response = await DioHelper.updateData(
        url: '/api/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        token: 'Bearer $token',
      );

      if (response.statusCode == 200) {
        String successMessage;
        if (response.data is String) {
          successMessage = response.data;
        } else if (response.data is Map) {
          successMessage = response.data['message']?.toString() ?? 'Password changed successfully.';
        } else {
          successMessage = 'Password changed successfully.';
        }
        emit(ChangePasswordSuccessState(successMessage));
      } else {
        String errorMessage;
        if (response.data is String) {
          errorMessage = response.data;
        } else if (response.data is Map) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message']?.toString() ?? 'Failed to change password.';
          } else if (response.data.containsKey('error')) {
            errorMessage = response.data['error']?.toString() ?? 'Failed to change password.';
          } else {
            errorMessage = 'Failed to change password.';
          }
        } else {
          errorMessage = 'Failed to change password.';
        }
        emit(ChangePasswordErrorState(errorMessage));
      }
    } on DioException catch (e) {
      print('DioException response data type: ${e.response?.data.runtimeType}');
      print('Full DioException response data: ${e.response?.data}');
      String errorMessage = 'Failed to change password. Please try again.';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is String) {
          errorMessage = e.response!.data;
        } else if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          errorMessage = e.response!.statusMessage ?? errorMessage;
        }
      } else {
        errorMessage = e.message ?? 'Network error. Check your connection.';
      }
      print("Dio Error during password change: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}");
      emit(ChangePasswordErrorState(errorMessage));
    } catch (e) {
      print(" General Error during password change: $e");
      emit(ChangePasswordErrorState('An unexpected error occurred during password change.'));
    }
  }



  Future<void> requestPasswordReset({ required String email }) async {
    emit(UserForgotPasswordLoading()); // نبدأ بحالة التحميل

    try {
      final response = await DioHelper.postData(
        url: FORGOT_PASSWORD_ENDPOINT, // استخدام الـ endpoint اللي عرفناه
        data: { "email": email },
      );

      final data = response.data;
      final String message = data['message'] ?? 'Password reset link sent. Check your email.';

      emit(UserForgotPasswordSuccess(message: message)); // حالة نجاح
    } on DioException catch (e) {
      String errorMessage = 'Failed to request password reset.';
      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      emit(UserForgotPasswordError(errorMessage)); // حالة خطأ
    } catch (e) {
      emit(UserForgotPasswordError(e.toString()));
    }
  }

  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? street,
    String? country,
  }) async {
    emit(UpdateProfileLoadingState());

    try {
      final token = await CacheHelper.getData(key: 'userToken');
      if (token == null) {
        emit(UpdateProfileErrorState('Authentication token not found. Please log in again.'));
        return;
      }

      final Map<String, dynamic> requestData = {};
      if (firstName != null) requestData['first_name'] = firstName;
      if (lastName != null) requestData['last_name'] = lastName;
      if (email != null) requestData['email'] = email;
      if (phone != null) requestData['phone'] = phone;
      if (city != null) requestData['city'] = city;
      if (street != null) requestData['street'] = street;
      if (country != null) requestData['country'] = country;

      if (requestData.isEmpty) {
        emit(UpdateProfileErrorState('No data provided for update.'));
        return;
      }

      final response = await DioHelper.updateData(
        url: '/api/auth/profile',
        data: requestData,
        token: 'Bearer $token',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final String message = data['message'] ?? 'Profile updated successfully.';
        final UserModel updatedUser = UserModel.fromJson(data['user']);
        await UserDataManager.saveUserData(token: token, user: updatedUser);
        emit(UpdateProfileSuccessState(updatedUser: updatedUser, message: message));
      } else {
        String errorMessage;
        if (response.data is String) {
          errorMessage = response.data;
        } else if (response.data is Map && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else {
          errorMessage = 'Failed to update profile: ${response.statusMessage}';
        }
        emit(UpdateProfileErrorState(errorMessage));
      }
    } on DioException catch (e) {
      String errorMessage = 'Error updating profile. Please try again.';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is String) {
          errorMessage = e.response!.data;
        } else if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          errorMessage = e.response!.statusMessage ?? errorMessage;
        }
      } else {
        errorMessage = e.message ?? 'Network error. Check your connection.';
      }
      print("Dio Error during profile update: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}");
      emit(UpdateProfileErrorState(errorMessage));
    } catch (e) {
      print("General Error during profile update: $e");
      emit(UpdateProfileErrorState('An unexpected error occurred during profile update.'));
    }
  }
}

