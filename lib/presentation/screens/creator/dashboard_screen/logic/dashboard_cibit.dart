import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/creator_profile_model.dart';
import 'dashboard_states.dart';
import 'package:path/path.dart';
class DashBoardCubit extends Cubit<DashBoardStates> {
  DashBoardCubit() : super((DashBoardInitialState()));
  static DashBoardCubit get(context) => BlocProvider.of(context);
  int dashboardCurrentIndex = 0;
  void dashboardChangeBottom(int index) {
    dashboardCurrentIndex = index;
    emit(DashboardChangeBottomNavState());
  }
  CreatorProfile? creatorProfile;


  Future<void> getProfileData() async {
    emit(ProfileLoading());
    final token = CacheHelper.getData(key: 'token');
    try {
      final response = await DioHelper.getData(
        url: CREATOR_PROFILE,
        token: 'Bearer $token',
      );
      print('Profile Data: ${response.data}'); // Debugging
      if (response.statusCode == 200 && response.data != null) {
        creatorProfile = CreatorProfile.fromJson(response.data);
        print(token);
        CacheHelper.saveData(key: 'userId', value: response.data['id']);
        // Debug deliveryValue
        print('Received deliveryValue: ${response.data['deliveryValue']}');
        print('Type of deliveryValue: ${response.data['deliveryValue']?.runtimeType}');
        if (creatorProfile!.professionId == null) {
          creatorProfile = creatorProfile!.copyWith(
            professionId: creatorProfile!.professionId ?? _getStoredProfessionId(),
          );
        }
        emit(ProfileLoaded(creatorProfile!));
      } else {
        emit(ProfileError('Failed to load profile: ${response.statusCode}'));
      }
    } catch (error) {
      print('Profile Error: $error');
      if (error is DioException) {
        print('Dio Error: ${error.response?.data}');
      }
      emit(ProfileError('Error: ${error.toString()}'));
    }
  }


  int? _getStoredProfessionId() {
    return CacheHelper.getData(key: 'professionId');
  }

  Future<void> updateStoreName(String newName) async {
    emit(UpdatingStoreNameLoading());
    final token = CacheHelper.getData(key: 'token');
    try {
      final response = await DioHelper.postData(
        url: '/api/creators/creator/update-name',
        token: 'Bearer $token',
        data: {'name': newName},
      );
      if (response.statusCode == 200 && response.data != null) {
        creatorProfile = creatorProfile?.copyWith(
          storeName: response.data['newName'],
          tokens: response.data['remainingCoins'],
        );
        getProfileData();
        emit(UpdateStoreNameLoaded(creatorProfile!));
      } else {
        getProfileData();
        emit(UpdateStoreNameError(response.data['error'] ?? 'Failed to update name'));
      }
    } catch (error) {
      getProfileData();
      emit(UpdateStoreNameError('Error updating name: $error'));
      print(error.toString());
    }
  }

  Future<void> logout() async {
    emit(LogoutLoadingState());
    try {
      clear();
      // مسح بيانات التخزين المحلي
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'userToken');

      // مسح حالة الإشعارات
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('address_seen');
      await prefs.remove('availability_seen');
      await prefs.remove('promotions_seen');
      await prefs.remove('payment_seen');
      await prefs.remove('profile_badge_seen');

      // تسجيل الخروج من الخدمات الخارجية
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // تحديث الحالة
      emit(LoggedOutState());
      creatorProfile = null;
    } catch (e) {
      emit(LogoutErrorState('فشل تسجيل الخروج'));
    }
  }
  void clear() {
    creatorProfile = null;
    emit(DashBoardInitialState());
  }


  Future<void> updateCreatorProfile({
    String? profileImage,
    String? coverPhoto,
    Map<String, dynamic>? availability,
    List<String>? paymentMethod,
    double? deliveryValue,
  }) async {
    emit(UpdateCreatorProfileLoading());
    final token = 'Bearer ${CacheHelper.getData(key: 'token')}';
    try {
      final current = creatorProfile;
      if (current == null) {
        emit(UpdateCreatorProfileError('No profile data'));
        return;
      }
      final Map<String, dynamic> data = {
        'profile_image': profileImage ?? current.profileImage,
        'cover_photo': coverPhoto ?? current.coverImage,
        'availability': availability != null
            ? jsonEncode(availability)
            : current.availability != null
            ? jsonEncode(current.availability)
            : null,
        'payment_method': paymentMethod != null
            ? jsonEncode(paymentMethod)
            : current.paymentMethod != null
            ? jsonEncode(current.paymentMethod)
            : null,
        'deliveryValue': deliveryValue ?? current.deliveryValue,
      };
      data.removeWhere((key, value) => value == null);

      debugPrint('Sending update data: $data');

      final response = await DioHelper.updateData(
        url: CREATORUPDATE,
        token: token,
        data: data,
      );
      if (response.statusCode == 200) {
        // تحديث الحالة المحلية
        creatorProfile = current.copyWith(
          profileImage: profileImage,
          coverImage: coverPhoto,
          availability: availability,
          paymentMethod: paymentMethod,
          deliveryValue: deliveryValue,
        );
        emit(UpdateCreatorProfileSuccess(creatorProfile!));
      } else {
        emit(UpdateCreatorProfileError('Failed: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint('Update error: $e');
      emit(UpdateCreatorProfileError(e.toString()));
    }
  }



  File? profileImage;
  var picker = ImagePicker();
  Future<bool> getProfileImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      print(pickedFile.path);
      await getProfileData();
      emit(getProfileImagePickedSuccess());
      return true;
    } else {
      profileImage = null;
      emit(getProfileImagePickedError());
      return false;
    }
  }


  File? coverImage;

  Future<void> getCoverImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      await getProfileData();
      emit(getCoverImagePickedSuccess());
    } else {
      coverImage = null;
      emit(getCoverImagePickedError());
    }
  }

  Future<void> uploadProfileImage() async {
    emit(AppUploadProfileImageLoading());
    if (profileImage == null) {
      emit(AppUploadProfileImageError());
      return;
    }
    try {
      final imageUrl = await _uploadImage(profileImage!);
      await updateCreatorProfile(
        profileImage: imageUrl,
        coverPhoto: creatorProfile?.coverImage,
        deliveryValue: creatorProfile?.deliveryValue,
        availability: creatorProfile?.availability,
        paymentMethod: creatorProfile?.paymentMethod,
      );

      await getProfileData();
      emit(AppUploadProfileImageSuccess());
    } catch (e) {
      print('Upload Profile Error: $e');
      emit(AppUploadProfileImageError());
    }
  }

  Future<void> uploadCoverImage() async {
    emit(AppUploadCoverImageLoading());
    if (coverImage == null) {
      emit(AppUploadCoverImageError());
      return;
    }
    try {
      final imageUrl = await _uploadImage(coverImage!);
      await updateCreatorProfile(
        coverPhoto: imageUrl,
        profileImage: creatorProfile?.profileImage,
        deliveryValue: creatorProfile?.deliveryValue,
        availability: creatorProfile?.availability,
        paymentMethod: creatorProfile?.paymentMethod,
      );


      await getProfileData();
      emit(AppUploadCoverImageSuccess());
    } catch (e) {
      print('Upload Cover Error: $e');
      emit(AppUploadCoverImageError());
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      print('Uploading image: ${image.path}'); // Debug
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
      });

      var response = await Dio().post(
        'https://www.mashru3i.com/upload.php',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response: ${response.data}'); // Debug
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.data);
        return decoded['url']; // Ensure this is a valid URL string
      } else {
        throw Exception('Upload failed with code ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e'); // Debug
      throw Exception('Image upload error: $e');
    }
  }


  bool showImageButtons = false;
  void toggleImageButtons() {
    showImageButtons = !showImageButtons;
    emit(ToggleImageButtonsState());
  }



  Future<void> updateAvailability(Map<String, dynamic> availability) async {
    emit(UpdateCreatorProfileLoading());
    final token = 'Bearer ${CacheHelper.getData(key: 'token')}';

    try {
      final currentProfile = creatorProfile;
      debugPrint('البيانات الحالية قبل التحديث:');
      debugPrint('صورة البروفايل: ${currentProfile?.profileImage}');
      debugPrint('صورة الغلاف: ${currentProfile?.coverImage}');
      debugPrint('وسائل الدفع: ${currentProfile?.paymentMethod}');
      debugPrint('قيمة التوصيل: ${currentProfile?.deliveryValue}');
      debugPrint('التوفر الحالي: ${currentProfile?.availability}');
      final data = {
        'profile_image': currentProfile?.profileImage,
        'cover_photo': currentProfile?.coverImage,
        'availability': jsonEncode(availability),
        'payment_method': currentProfile?.paymentMethod != null
            ? jsonEncode(currentProfile!.paymentMethod)
            : null,
        'deliveryValue': currentProfile?.deliveryValue,
      };

      final response = await DioHelper.updateData(
        url: CREATORUPDATE,
        token: token,
        data: data,
      );


      if (response.statusCode == 200) {

        creatorProfile = creatorProfile?.copyWith(availability: availability);

        debugPrint('تم تحديث التوفر بنجاح: ${response.data}');
        emit(UpdateCreatorProfileSuccess(creatorProfile!));
      } else {
        debugPrint('فشل التحديث: ${response.statusCode} - ${response.data}');
        emit(UpdateCreatorProfileError('فشل في التحديث: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء التحديث: ${e.toString()}');
      emit(UpdateCreatorProfileError('خطأ غير متوقع: ${e.toString()}'));
    }
  }


  Future<void> requestTokens(double amount) async {

    emit(RequestTokensLoadingState());

    final token = CacheHelper.getData(key: 'token');

    if (token == null) {
      emit(RequestTokensErrorState('Authentication token not found. Please log in again.'));
      return;
    }

    if (amount <= 0) {
      emit(RequestTokensErrorState('Amount must be a positive number.'));
      return;
    }

    try {
      final response = await DioHelper.postData(
        url: '/api/token-requests/',
        token: 'Bearer $token',
        data: {
          'amount': amount,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true) {
          emit(RequestTokensSuccessState(
            response.data['message'] ?? 'Token request sent successfully!',
          ));
          await getProfileData();
        } else {
          emit(RequestTokensErrorState(
            response.data['message'] ?? 'Failed to send token request.',
          ));
        }
      } else {
        emit(RequestTokensErrorState(
          response.data['message'] ?? 'Server error: ${response.statusCode}',
        ));
      }
    } on DioException catch (e) {
      print('Dio Request Tokens Error: ${e.response?.data ?? e.message}');
      emit(RequestTokensErrorState(
        e.response?.data['message'] ?? 'Network error or server issue.',
      ));
    } catch (error) {
      print('General Request Tokens Error: $error');
      emit(RequestTokensErrorState('An unexpected error occurred: ${error.toString()}'));
    }
  }



  Future<void> deleteUserAccount({
    required String jwtToken,
    VoidCallback? onSuccess,
    void Function(String? message)? onError,
  }) async {
    emit(LogoutLoadingState()); // نستخدم حالة جاهزة عنا - أو اعمل حالة خاصة Delete
    try {
      final dio = Dio();
      final resp = await dio.delete(
        'http://46.202.175.64:3000/api/auth/users/me', // أو استبدل بـ Endpoints جاهز عندك
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode == 200) {
        // امسح التوكن والبيانات المحلية مثل logout
        await CacheHelper.removeData(key: 'token');
        await CacheHelper.removeData(key: 'userToken');

        // إحتمال عندك مفاتيح إضافية بتشيلها وقت الـ logout — خليها نفس منطقك تماماً:
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('address_seen');
          await prefs.remove('availability_seen');
          await prefs.remove('promotions_seen');
          await prefs.remove('payment_seen');
          await prefs.remove('profile_badge_seen');
        } catch (_) {}

        // لو بتسجّل خروج من Google/Firebase
        try { await GoogleSignIn().signOut(); } catch (_) {}
        try { await FirebaseAuth.instance.signOut(); } catch (_) {}

        creatorProfile = null;
        emit(LoggedOutState());
        onSuccess?.call();
      } else {
        final msg = (resp.data is Map && resp.data['message'] != null)
            ? resp.data['message'].toString()
            : 'Delete failed (${resp.statusCode})';
        emit(LogoutErrorState(msg));
        onError?.call(msg);
      }
    } catch (e) {
      emit(LogoutErrorState('Network/Server error'));
      onError?.call(e.toString());
    }
  }

}






