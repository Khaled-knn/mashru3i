import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../../core/helper/user_data_manager.dart';
import '../../../../../../core/theme/color.dart';
import '../../../../../../data/models/user_model.dart';
import '../../../log_in/logic/user_cibit.dart';
import '../../../log_in/logic/user_state.dart';
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _countryController;

  bool _isEditing = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentUser = UserDataManager.getUserModel();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: _currentUser?.firstName);
    _lastNameController = TextEditingController(text: _currentUser?.lastName);
    _emailController = TextEditingController(text: _currentUser?.email);
    _phoneController = TextEditingController(text: _currentUser?.phone);
    _cityController = TextEditingController(text: _currentUser?.city);
    _streetController = TextEditingController(text: _currentUser?.street);
    _countryController = TextEditingController(text: _currentUser?.country);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _updateUIWithNewData(UserModel updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      _initializeControllers();
      _isEditing = false;
      _isLoading = false;
    });
  }

  void _saveChanges(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final cubit = LoginCubit.get(context);
      cubit.updateUserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        street: _streetController.text,
        country: _countryController.text,
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeControllers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('personalInformation'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: popButton(context),
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              child: IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit, color: textColor),
                onPressed: _toggleEditMode,
                tooltip: _isEditing ? 'Cancel'.tr() : 'Edit'.tr(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isEditing ? _buildSaveButton(context) : null,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is UpdateProfileLoadingState) {
            // No SnackBar needed here, as the button itself will show loading
          } else if (state is UpdateProfileSuccessState) {
            _updateUIWithNewData(state.updatedUser);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: TextStyle(color: Colors.black)),
                backgroundColor: Theme.of(context).primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is UpdateProfileErrorState) {
            setState(() {
              _isLoading = false; // Set loading to false on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (_currentUser?.isVerified ?? false)
                  _buildVerifiedBanner(context),
                if (!(_currentUser?.isVerified ?? false))

                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildEditableInfoRow(
                                context,
                                icon: Icons.person_outline,
                                label: 'firstName'.tr(),
                                controller: _firstNameController,
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'firstNameRequired'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildEditableInfoRow(
                                context,
                                icon: Icons.person_outline,
                                label: 'lastName'.tr(),
                                controller: _lastNameController,
                                enabled: _isEditing,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'lastNameRequired'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildEditableInfoRow(
                                context,
                                icon: Icons.email_outlined,
                                label: 'emailAddress'.tr(),
                                controller: _emailController,
                                enabled: false,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'emailRequired'.tr();
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'invalidEmail'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildEditableInfoRow(
                                context,
                                icon: Icons.phone_android_outlined,
                                label: 'phoneNumber'.tr(),
                                controller: _phoneController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'phoneRequired'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(
                                context,
                                icon: Icons.star_outline,
                                label: 'points'.tr(),
                                value: '${_currentUser?.points ?? 0} ${'points'.tr()}',
                                trailing: (_currentUser?.points ?? 0) > 0
                                    ? TextButton(
                                  onPressed: () {
                                    // Navigate to points screen
                                  },
                                  child: Text(
                                    'redeem'.tr(),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Text(
            'accountVerified'.tr(),
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  //

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
        ),
        onPressed: () => _saveChanges(context),
        child: Text(
          'saveChanges'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required TextEditingController controller,
        required bool enabled,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    errorStyle: const TextStyle(
                      fontSize: 12,
                      height: 0.6,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black : Colors.grey[700],
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      context, {
        required IconData icon,
        required String label,
        required String value,
        Widget? trailing,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}