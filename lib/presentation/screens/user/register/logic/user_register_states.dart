import 'package:flutter/foundation.dart';

@immutable
abstract class UserRegisterState {}

class UserRegisterInitial extends UserRegisterState {}

class UserRegisterLoading extends UserRegisterState {}

class UserRegisterSuccess extends UserRegisterState {
  final int? userId;
  final String token;
  UserRegisterSuccess({required this.userId, required this.token});
}

class UserRegisterError extends UserRegisterState {
  final String error;
  UserRegisterError(this.error);
}
class UserChangeVisibilityIconState extends UserRegisterState {}
class UserChangeConfirmVisibilityIconState extends UserRegisterState {}
class UserRegisterEmailVerificationNeeded extends UserRegisterState {}




