import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helper/FcmService.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../widgets/compnents.dart';
import '../../dashboard_screen/logic/dashboard_cibit.dart';
import '../logic/creator_register_cubit.dart';
import '../logic/creator_register_state.dart';
import 'form.dart'; // تأكد من استيراد ملف الـ form

class CreatorRegister extends StatelessWidget {
  const CreatorRegister({super.key});
  @override
  Widget build(BuildContext context) {
    final FcmService fcmService = FcmService();
    return BlocProvider(
      create: (BuildContext context) => CreatorRegisterCubit(),
      child: BlocConsumer<CreatorRegisterCubit, CreatorRegisterState>(
        listener: (context, state)async  {
          if (state is CreatorRegisterSuccess) {
            CacheHelper.saveData(key: 'userType', value: 'creator');

            final dynamic idData = CacheHelper.getData(key: 'userId');
            if (idData == null) {
              print('Error: userId not found in cache');
              return; // أو تعامل مع الخطأ كما تراه مناسبًا
            }
            final int creatorId = idData is int ? idData : int.parse(idData.toString());

            await fcmService.requestNotificationPermissions();

            try {
              String? fcmToken = await fcmService.getFcmToken();
              if (fcmToken != null) {
                await fcmService.sendFcmTokenToBackend(
                  userId: creatorId,
                  userType: 'creator',
                  fcmToken: fcmToken,
                );
              } else {
                print("⚠️ FCM token is null on creator register, will wait for onTokenRefresh");
              }
            } catch (e) {
              print('❌ Error getting FCM token on creator register: $e');
            }

            fcmService.listenToTokenChanges(creatorId, 'creator');

            context.read<DashBoardCubit>().clear();
            await context.read<DashBoardCubit>().getProfileData();
            context.go('/PendingApprovalScreen');
          }
          else if (state is CreatorRegisterError) {
            showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          // هنا نستخلص حالة التحميل الصحيحة من الـ 'state'
          final bool isLoading = state is CreatorRegisterLoading;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              leading: popButton(context),
              title: Text(
                LocaleKeys.join_as_creator.tr(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            body: ListView(
              children: [
                Stack(
                  children: [
                    // withNav(context), // تأكد ما هو دور withNav، إذا كان لا يسبب مشاكل في الـ layout اتركه
                    // نمرر حالة التحميل إلى CreatorRegisterForm
                    CreatorRegisterForm(isLoading: isLoading), // هنا التعديل المهم
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