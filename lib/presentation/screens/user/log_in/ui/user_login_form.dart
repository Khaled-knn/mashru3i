import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/presentation/screens/user/log_in/logic/user_cibit.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/pofession_model.dart';
import '../../../../profession/logic/profession_cubit.dart';
import '../../../../profession/logic/profession_state.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../logic/user_state.dart';

class UserLoginForm extends StatefulWidget {
  const UserLoginForm();

  @override
  State<UserLoginForm> createState() => _UserLoginForm();
}

class _UserLoginForm extends State<UserLoginForm> {
  TextEditingController userEmailAddress = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  var formKey = GlobalKey<FormState>();
  int professionId = 0;
  get state => null;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit , LoginState>(
      builder:  (context , state){
        var cubit = LoginCubit.get(context);
        return  Padding(
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
                        controller: userEmailAddress,
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
                        controller: userPassword,
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
                        obscureText: cubit.isPasswordShow,

                        keyboardType: TextInputType.visiblePassword,
                        maxLines: 1,
                        suffixIcon:cubit.isPasswordShow ? Icons.visibility_off : Icons.visibility,
                      ),
                      const SizedBox(height: 10),
                      ConditionalBuilder(
                        condition: state is! LoginLoadingState,
                        builder: (context) => CustomButton(
                          text: LocaleKeys.login.tr(),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              cubit.userLogin(
                                  userEmailAddress.text,
                                  userPassword.text);
                            }
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
                            style: TextStyle(color: textColor)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}