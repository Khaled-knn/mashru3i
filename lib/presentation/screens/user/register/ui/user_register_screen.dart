import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';
import 'package:mashrou3i/presentation/screens/user/register/ui/user_register_form.dart';
import '../../../../../core/helper/FcmService.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../widgets/compnents.dart';
import '../logic/user_register_cubit.dart';
import '../logic/user_register_states.dart';
class UserRegisterScreen extends StatelessWidget {
  const UserRegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {

    final FcmService fcmService = FcmService();    return  BlocProvider(
      create: (BuildContext context)=>UserRegisterCubit(),
      child: BlocConsumer<UserRegisterCubit ,UserRegisterState>(
        listener: (context, state)async  {
          if (state is UserRegisterSuccess) {
            final int userId = CacheHelper.getData(key: 'userIdTwo');
            await fcmService.requestNotificationPermissions();
            String? fcmToken = await fcmService.getFcmToken();
            if (fcmToken != null) {
              await fcmService.sendFcmTokenToBackend(
                userId: userId,
                userType: 'user',
                fcmToken: fcmToken,
              );
            }
            fcmService.listenToTokenChanges(userId, 'user');

            context.go('/UserLayout');
          }
          else if (state is UserRegisterError) {
            showErrorDialog(context, state.error);
          }
        },
         builder: (context , state){
           return Scaffold(
             resizeToAvoidBottomInset: true,
             appBar: AppBar(
               centerTitle: true,
               backgroundColor: Theme.of(context).primaryColor,
               leading: popButton(context),
               title: Text(
                 LocaleKeys.sign_up.tr(),
                 style: Theme.of(context).textTheme.titleSmall,
               ),
             ),
             body: ListView(
               children: [
                 Stack(
                   children: [
                     withNav(context),
                     const UserRegisterForm(),
                   ],
                 ),
               ],
             ),
           );
         },
      ),
    );
  }
}
