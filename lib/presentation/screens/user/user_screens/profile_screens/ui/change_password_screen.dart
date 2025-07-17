import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/color.dart';
import '../../../../../../core/theme/LocaleKeys.dart';
import '../../../../../widgets/compnents.dart';
import '../../../log_in/logic/user_cibit.dart';
import '../../../log_in/logic/user_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(LocaleKeys.changePassword.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold ,fontSize: 18)),
        centerTitle: true,
        elevation: 0,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: popButton(context),
      ),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message , style: TextStyle(color: Colors.black),),
                backgroundColor:primaryColor,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ChangePasswordErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.updatePassword.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 20
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Stack(
                    children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Card(color: Colors.white, child: _buildForm(context))),
                    ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildForm(BuildContext context) {
    final state = context.watch<LoginCubit>().state;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 24),

            /// Current Password
            _buildPasswordField(
              label: LocaleKeys.currentPassword.tr(),
              controller: _currentPasswordController,
              isVisible: _isCurrentPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                });
              },
              validator: (value) =>
              value == null || value.isEmpty
                  ? LocaleKeys.enterCurrentPassword.tr()
                  : null,
              primaryColor: primaryColor,
              labelColor: Colors.black,
              icon: Icons.lock,
              obscureText: !_isCurrentPasswordVisible,
            ),

            const SizedBox(height: 20),

            /// New Password
            _buildPasswordField(
              label: LocaleKeys.newPassword.tr(),
              controller: _newPasswordController,
              isVisible: _isNewPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.enterNewPassword.tr();
                }
                if (value.length < 6) {
                  return LocaleKeys.passwordTooShort.tr();
                }
                return null;
              },
              primaryColor: primaryColor,
              labelColor: Colors.black,
              icon: Icons.lock_outline,
              obscureText: !_isNewPasswordVisible,
            ),
            const SizedBox(height: 20),

            /// Confirm New Password
            _buildPasswordField(
              label: LocaleKeys.confirmNewPassword.tr(),
              controller: _confirmNewPasswordController,
              isVisible: _isConfirmNewPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.confirmYourPassword.tr();
                }
                if (value != _newPasswordController.text) {
                  return LocaleKeys.passwordsDoNotMatch.tr();
                }
                return null;
              },
              primaryColor: primaryColor,
              labelColor: Colors.black,
              icon: Icons.lock_reset,
              obscureText: !_isConfirmNewPasswordVisible,
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              color: Colors.transparent,
              child: ElevatedButton(
                onPressed: state is ChangePasswordLoadingState
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<LoginCubit>().changeUserPassword(
                      currentPassword: _currentPasswordController.text,
                      newPassword: _newPasswordController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: state is ChangePasswordLoadingState
                      ? Colors.grey.shade400
                      : primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state is ChangePasswordLoadingState
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : Text(
                  LocaleKeys.changePassword.tr(),
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 16),

            Text(
              LocaleKeys.passwordNote.tr(),
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600 , fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required FormFieldValidator<String> validator,
    required IconData icon,
    required bool obscureText,
    required Color primaryColor,
    required Color labelColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor , fontSize: 12, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Container(
          width: 20,
            
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10)
            ),
          child: Icon(icon, color: textColor , size: 20,),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
              color: primaryColor),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
