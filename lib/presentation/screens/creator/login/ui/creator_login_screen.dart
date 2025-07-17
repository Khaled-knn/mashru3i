import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/helper/FcmService.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../widgets/compnents.dart';
import '../logic/creator_login_cubit.dart';
import '../logic/creator_login_states.dart';
import 'creator_login_form.dart';

class CreatorLoginScreen extends StatefulWidget {
  const CreatorLoginScreen({super.key});

  @override
  State<CreatorLoginScreen> createState() => _CreatorLoginScreenState();
}

class _CreatorLoginScreenState extends State<CreatorLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FcmService fcmService = FcmService();
    return BlocProvider(
      create: (BuildContext context) => CreatorLoginCubit(),
      child: BlocConsumer<CreatorLoginCubit, CreatorLoginState>(
        listener: (context, state) async {
          if (state is CreatorLoginSuccessState) {
            CacheHelper.saveData(key: 'userType', value: 'creator');

            final dynamic idData = state.responseData['creatorId'];
            if (idData == null) {
              print('Error: creatorId is null');
              return;
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
                print("FCM token is null on creator login, will wait for onTokenRefresh");
              }
            } catch (e) {
              print('Error getting FCM token on creator login: $e');
            }

            fcmService.listenToTokenChanges(creatorId, 'creator');

            if (state.responseData['status'] == 'approved') {
              context.go('/DashBoardScreen');
            } else {
              context.go('/PendingApprovalScreen');
            }
          }
          else if (state is CreatorLoginErrorState) {
            showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              leading: popButton(context),
              title: Text(
                LocaleKeys.userLogin.tr(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            body: ListView(
              children: [
                Stack(
                  children: [
                    withNav(context),
                    Column(
                      children: [
                        const CreatorLoginForm(),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.no_account_yet.tr()),
                    TextButton(
                      onPressed: () {
                        context.push('/creatorRegister');
                      },
                      child: Text(
                        LocaleKeys.sign_up.tr(),
                        style: TextStyle(color: textColor),
                      ),
                    ),
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