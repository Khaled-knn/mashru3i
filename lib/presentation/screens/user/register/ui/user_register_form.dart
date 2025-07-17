import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../../../creator/register/logic/creator_register_state.dart';
import '../logic/user_register_cubit.dart';
import '../logic/user_register_states.dart';

class UserRegisterForm extends StatefulWidget {
  const UserRegisterForm({super.key});

  @override
  State<UserRegisterForm> createState() => _UserRegisterFormState();
}

class _UserRegisterFormState extends State<UserRegisterForm> {
  TextEditingController userFirstName = TextEditingController();
  TextEditingController userLastName = TextEditingController();
  TextEditingController userEmailAddress = TextEditingController();
  TextEditingController userPhoneNumber = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController userConfirmPassword = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegisterCubit ,UserRegisterState>(
      builder:(context , state){
        var cubit = UserRegisterCubit.get(context);
        return Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BackgroundForm(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormInput(
                          controller: userFirstName,
                          label: LocaleKeys.first_name.tr(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return LocaleKeys.email_required.tr();
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          prefixIcon: IconBroken.Profile,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomFormInput(
                          controller: userLastName,
                          label: LocaleKeys.last_name.tr(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return LocaleKeys.last_name_required.tr();
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          prefixIcon: IconBroken.User,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Text(
                          '+961',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomFormInput(
                          controller: userPhoneNumber,
                          label: LocaleKeys.phone_number.tr(),
                          prefixIcon: IconBroken.Call,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return LocaleKeys.phone_required.tr();
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
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
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    obscureText: cubit.isPasswordShow,
                    suffixClicked: () {
                      cubit.changeVisibilityIcon();
                    },
                    suffixIcon: cubit.isPasswordShow
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  const SizedBox(height: 10),
                  CustomFormInput(
                    controller: userConfirmPassword,
                    label: LocaleKeys.confirm_password.tr(),
                    prefixIcon: Icons.key,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.confirm_password_required.tr();
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    suffixIcon: cubit.isPasswordConfirmShow
                        ? Icons.visibility_off
                        : Icons.visibility,
                    obscureText: cubit.isPasswordConfirmShow,
                    suffixClicked: (){
                      cubit.changeConfirmVisibilityIcon();
                    },
                  ),
                  const SizedBox(height: 10),
                  ConditionalBuilder(
                    condition: state is UserRegisterLoading,
                    builder: (context) => Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Theme.of(context).primaryColor,
                        )),
                    fallback: (context) => CustomButton(
                      text: LocaleKeys.sign_up.tr(),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          UserRegisterCubit.get(context).postRegisterData(
                              firstName: userFirstName.text,
                              lastName: userLastName.text,
                              email: userEmailAddress.text,
                              phone: userPhoneNumber.text,
                              password: userPassword.text,
                              confirmPassword: userConfirmPassword.text,
                          );
                        }
                      },
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
