import 'package:flutter/foundation.dart';

@immutable
abstract class CreatorRegisterState {}

class CreatorRegisterInitial extends CreatorRegisterState {}

class CreatorRegisterLoading extends CreatorRegisterState {}

class CreatorRegisterSuccess extends CreatorRegisterState {
  final int? creatorId;
  final String token;
  CreatorRegisterSuccess({required this.creatorId, required this.token});
}

class CreatorRegisterError extends CreatorRegisterState {
  final String error;
  CreatorRegisterError(this.error);
}
class ChangeVisibilityIconState extends CreatorRegisterState {}
class changeConfirmVisibilityIconState extends CreatorRegisterState {}


