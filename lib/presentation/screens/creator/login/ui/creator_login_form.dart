import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../logic/creator_login_cubit.dart';
import '../logic/creator_login_states.dart';

class CreatorLoginForm extends StatefulWidget {
  const CreatorLoginForm();

  @override
  State<CreatorLoginForm> createState() => _CreatorLoginForm();
}

class _CreatorLoginForm extends State<CreatorLoginForm> {
  TextEditingController creatorEmailAddress = TextEditingController();
  TextEditingController creatorPassword = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatorLoginCubit , CreatorLoginState>(
      builder: (context , state) {
        var cubit = CreatorLoginCubit.get(context);
        return Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              BackgroundForm(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFormInput(
                      controller: creatorEmailAddress,
                      label: LocaleKeys.email_address.tr(),
                      prefixIcon: IconBroken.Message,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.email_required.tr();
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    CustomFormInput(
                      controller: creatorPassword,
                      label: LocaleKeys.password.tr(),
                      prefixIcon: IconBroken.Lock,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.password_required.tr();
                        }
                        return null;
                      },
                      suffixClicked: () {
                        cubit.changeVisibilityIcon();
                      },
                      suffixIcon: cubit.isPasswordShow ? Icons.visibility_off : Icons.visibility,
                      keyboardType: TextInputType.visiblePassword,
                      maxLines: 1,
                      obscureText: cubit.isPasswordShow,
                    ),

                    const SizedBox(height: 10),
                    ConditionalBuilder(
                      condition: state is!  CreatorLoginLoadingState,
                      builder: (context) => CustomButton(
                        text: LocaleKeys.login.tr(),
                        onPressed: () {
                          CreatorLoginCubit.get(context).creatorLogin(
                            email: creatorEmailAddress.text,
                            password: creatorPassword.text,
                          );
                        },
                        textColor: Colors.black,
                      ),
                      fallback: (context) => Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context.push('/ForgetPassword');

                      },
                      child: Text(
                        LocaleKeys.forget_password.tr(),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      }
    );
  }
}