import 'dart:convert'; // ممكن تحتاجه إذا كنت بتتعامل مع JSON يدوياً (بس هنا مو كثير)
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/screens/user/log_in/logic/user_cibit.dart';
import 'package:mashrou3i/presentation/screens/user/log_in/logic/user_state.dart';
import '../../../../../core/helper/FcmService.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/custom_button.dart';
import 'user_login_form.dart';

class UserLogin extends StatelessWidget {
  const UserLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final FcmService fcmService = FcmService();

    return BlocConsumer<LoginCubit, LoginState>(
        listener: (context , state ) async {
          if (state is LoginSuccessState) {
            final int userId = state.responseData['user']['id'];

            await fcmService.requestNotificationPermissions();

            try {
              String? fcmToken = await fcmService.getFcmToken();
              if (fcmToken != null) {
                await fcmService.sendFcmTokenToBackend(
                  userId: userId,
                  userType: 'user',
                  fcmToken: fcmToken,
                );
              } else {
                print("FCM token is null on login, will wait for onTokenRefresh");
              }
            } catch (e) {
              print("Error getting FCM token on login: $e");
            }

            fcmService.listenToTokenChanges(userId, 'user');

            context.go('/UserLayout');
          }
          else if (state is LoginErrorState) {
            showErrorDialog(context, state.error);
          }
        },
        builder: (context , state ){
          final bool isLoading = state is LoginLoadingState;

          return  Scaffold(
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

                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30
                      ),
                      child: Column(
                        children: [
                          const UserLoginForm(),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.no_account_yet.tr()),
                    TextButton(
                      onPressed: () {
                        context.push('/UserRegisterScreen');
                      },
                      child:  Text(
                        LocaleKeys.sign_up.tr()
                        ,style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                SocialButton(
                  text: isLoading ? '' : 'Log in with Google',
                  icon: isLoading ? null : FontAwesomeIcons.google,
                  iconWidget: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                      : null,
                  iconGradient: !isLoading
                      ? LinearGradient(
                    colors: [Colors.red, Colors.amber, Colors.green, Colors.blue],
                  )
                      : null,
                  elevation: 3.0,
                  onPressed: isLoading ? null : () => LoginCubit.get(context).signInWithGoogle(),
                  backgroundColor: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25),
                ),
              ],
            ),
          );
        }
    );
  }
}

Widget SocialButton({
  required String text,
  IconData? icon,
  Widget? iconWidget,
  Gradient? iconGradient,
  Color? iconColor,
  Color? textColor,
  Color? backgroundColor,
  double? horizontalPadding,
  double? verticalPadding,
  double? iconSize,
  double? elevation,
  BorderRadius? borderRadius,
  VoidCallback? onPressed,
}) {
  // Handle icon with optional gradient
  Widget? resolvedIconWidget;

  if (iconWidget != null) {
    resolvedIconWidget = iconWidget;
  } else if (icon != null) {
    resolvedIconWidget = iconGradient != null
        ? ShaderMask(
      shaderCallback: (Rect bounds) => iconGradient.createShader(bounds),
      child: Icon(
        icon,
        size: iconSize ?? 24,
        color: Colors.white,
      ),
    )
        : Icon(
      icon,
      size: iconSize ?? 24,
      color: iconColor,
    );
  }

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding ?? 50.0,
      vertical: verticalPadding ?? 5,
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor ?? Colors.black,
          backgroundColor: backgroundColor ?? Colors.white,
          elevation: elevation ?? 2.0,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        child: (onPressed == null && iconWidget != null && text.isEmpty)
            ? Center(child: iconWidget)
            : Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 40, start: 20),
              child: resolvedIconWidget,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}