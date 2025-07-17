import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/pofession_model.dart';
import '../../../../profession/logic/profession_cubit.dart';
import '../../../../profession/logic/profession_state.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../logic/creator_register_cubit.dart';
import '../logic/creator_register_state.dart';

class CreatorRegisterForm extends StatefulWidget {
  final bool isLoading;

  const CreatorRegisterForm({super.key, this.isLoading = false});

  @override
  State<CreatorRegisterForm> createState() => _CreatorRegisterFormState();
}

class _CreatorRegisterFormState extends State<CreatorRegisterForm> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController storeName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  var formKey = GlobalKey<FormState>();
  int professionId = 0;


  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    emailAddress.dispose();
    phoneNumber.dispose();
    storeName.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final professionCubit = context.read<ProfessionCubit>();

    final creatorRegisterCubit = context.read<CreatorRegisterCubit>();
    final bool isFormLoading = widget.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: BlocBuilder<ProfessionCubit, ProfessionState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(color: Colors.grey.shade300, width: 1.0),
                    ),
                    child: DropdownButton<ProfessionModel>(
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      underline: Container(height: 1, color: Colors.transparent),
                      value: professionCubit.selectedProfession,
                      hint: Text(LocaleKeys.choose_profession.tr()),
                      items: professionCubit.professionList.map((profession) {
                        return DropdownMenuItem<ProfessionModel>(
                          value: profession,
                          child: Text(profession.name ?? ""),
                        );
                      }).toList(),
                      onChanged: (ProfessionModel? value) {
                        professionCubit.selectProfession(value);
                        if (value != null) {
                          professionId = value.id!;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            BackgroundForm(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormInput(
                          controller: firstName,
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
                          controller: lastName,
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
                    controller: emailAddress,
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
                          controller: phoneNumber,
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
                    controller: storeName,
                    label: LocaleKeys.store_name.tr(),
                    prefixIcon: IconBroken.Bag,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.store_name_required.tr();
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  CustomFormInput(
                    controller: password,
                    label: LocaleKeys.password.tr(),
                    prefixIcon: IconBroken.Lock,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.password_required.tr();
                      }
                      return null;
                    },
                    obscureText: creatorRegisterCubit.isPasswordShow,
                    suffixClicked: () {
                      creatorRegisterCubit.changeVisibilityIcon();
                    },
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    suffixIcon: creatorRegisterCubit.isPasswordShow
                        ? Icons.visibility_off
                        : Icons.visibility,
                    suffixColor: creatorRegisterCubit.isPasswordShow
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 10),
                  CustomFormInput(
                    controller: confirmPassword,
                    label: LocaleKeys.confirm_password.tr(),
                    prefixIcon: Icons.key,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.confirm_password_required.tr();
                      }
                      if (value != password.text) {
                        return "passwords not match";
                      }
                      return null;
                    },
                    obscureText: creatorRegisterCubit.isPasswordConfirmShow,
                    suffixClicked: () {
                      creatorRegisterCubit.changeConfirmVisibilityIcon();
                    },
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    suffixIcon: creatorRegisterCubit.isPasswordConfirmShow
                        ? Icons.visibility_off
                        : Icons.visibility,
                    suffixColor: creatorRegisterCubit.isPasswordConfirmShow
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 10),
                  ConditionalBuilder(
                    condition: isFormLoading,
                    fallback: (context) => CustomButton(
                      text: LocaleKeys.sign_up.tr(),
                      onPressed: isFormLoading ? null : () {
                        if (formKey.currentState!.validate()) {
                          if (professionId == 0) {
                            showErrorDialog(context, LocaleKeys.choose_profession.tr());
                            return;
                          }
                          creatorRegisterCubit.postRegisterData(
                            professionId: professionId,
                            firstName: firstName.text,
                            lastName: lastName.text,
                            email: emailAddress.text,
                            phone: phoneNumber.text,
                            storeName: storeName.text,
                            password: password.text,
                            confirmPassword: confirmPassword.text,
                          );
                        }
                      },
                      textColor: Colors.black,
                    ),
                    builder: (context) => Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children:
                    [
                      Text(LocaleKeys.already_have_account.tr()),
                      TextButton(
                        onPressed: (){
                          context.push('/CreatorLoginScreen');
                        },
                        child: Text(LocaleKeys.login.tr() , style: TextStyle(
                          color: textColor,
                        ),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}