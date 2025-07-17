import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/user_cubit/user_states.dart';

import '../screens/user_help_center_screen.dart';
import '../screens/user_home_screen.dart';
import '../screens/user_order_screen.dart';
import '../screens/user_profile_screen.dart';

class UserCubit extends Cubit<UserStates>{
  UserCubit() : super(UserInitialState());
  static UserCubit get(context) =>BlocProvider.of(context);


  int currentIndex = 0 ;
  List<Widget> bottomScreens = [
    UserHomeScreen(),
    UserOrdersScreen(),
    UserHelpCenterScreen(),
    UserProfileScreen(),
  ];

  void changeBottom(int index){
    currentIndex=index;
    emit(UserChangeBottomNavState());
  }



}