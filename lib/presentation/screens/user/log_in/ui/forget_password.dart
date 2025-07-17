import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/theme/color.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../logic/user_cibit.dart';
import '../logic/user_state.dart';



class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController userEmailAddress = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userEmailAddress.dispose();
    super.dispose();
  }

  void _showMessageDialog(BuildContext context, String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: isSuccess ? textColor : Colors.red)),
        content: Text(message , style: TextStyle(fontSize: 15 ,),textAlign: TextAlign.center,),
        actions: <Widget>[
          TextButton(
            child: Text(LocaleKeys.ok.tr() , style: TextStyle(fontWeight: FontWeight.bold, color: textColor),textAlign: TextAlign.center,), // أو "حسناً"
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isSuccess) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: popButton(context),
        title: Text(
          LocaleKeys.forget_password.tr(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              withNav(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      BackgroundForm(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(LocaleKeys.resetPasswordHint.tr()),
                            const SizedBox(height: 20),
                            CustomFormInput(
                              controller: userEmailAddress,
                              label: LocaleKeys.email_address.tr(),
                              prefixIcon: IconBroken.Message,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LocaleKeys.email_required.tr();
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            BlocConsumer<LoginCubit, LoginState>(
                              listener: (context, state) {
                                if (state is UserForgotPasswordSuccess) {
                                  _showMessageDialog(
                                    context,
                                    LocaleKeys.success.tr(),
                                    '${LocaleKeys.password_reset_email_sent_to.tr()} ${userEmailAddress.text}. ${LocaleKeys.check_spam_folder.tr()}',
                                    isSuccess: true,
                                  );
                                } else if (state is UserForgotPasswordError) {

                                  _showMessageDialog(
                                    context,
                                    LocaleKeys.error.tr(),
                                    state.error,
                                    isSuccess: false,
                                  );
                                }
                              },
                              builder: (context, state) {
                                return ConditionalBuilder(
                                  condition: state is! UserForgotPasswordLoading,
                                  builder: (context) => CustomButton(
                                    text: LocaleKeys.submit.tr(),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        LoginCubit.get(context).requestPasswordReset(
                                          email: userEmailAddress.text,
                                        );
                                      }
                                    },
                                    textColor: Colors.black,
                                  ),
                                  fallback: (context) => Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        color: Theme.of(context).primaryColor,
                                      )),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}