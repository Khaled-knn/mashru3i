  import 'package:easy_localization/easy_localization.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:mashrou3i/presentation/screens/user/user_screens/profile_screens/logic/address_cubit.dart'; // 🎯 تأكد من المسار الصحيح
  import 'package:mashrou3i/presentation/screens/user/user_screens/profile_screens/logic/address_state.dart'; // 🎯 تأكد من المسار الصحيح لحالات AddressCubit
  import 'package:mashrou3i/presentation/widgets/compnents.dart';
  import '../../../../../../core/helper/user_data_manager.dart';
  import '../../../../../../core/theme/color.dart';
  import '../../../log_in/logic/user_cibit.dart';
  import '../../../log_in/logic/user_state.dart';


  class AddressScreen extends StatefulWidget {
    const AddressScreen({super.key});

    @override
    State<AddressScreen> createState() => _AddressScreenState();
  }

  class _AddressScreenState extends State<AddressScreen> {
    bool _isLocating = false;
    late TextEditingController _cityController;
    late TextEditingController _streetController;
    late TextEditingController _countryController;

    bool _isEditing = false;
    bool _isSaving = false;
    final _formKey = GlobalKey<FormState>();

    @override
    void initState() {
      super.initState();
      final currentUser = UserDataManager.getUserModel();
      _cityController = TextEditingController(text: currentUser?.city);
      _streetController = TextEditingController(text: currentUser?.street);
      _countryController = TextEditingController(text: currentUser?.country ?? 'Lebanon');
    }

    @override
    void dispose() {
      _cityController.dispose();
      _streetController.dispose();
      _countryController.dispose();
      super.dispose();
    }

    void _saveChanges(BuildContext context) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isSaving = true;
        });

        final cubit = context.read<UserAddressCubit>();
        cubit.updateUserAddress(
          city: _cityController.text,
          street: _streetController.text,
          country: _countryController.text,
        );
      }
    }

    void _getAutoLocation(BuildContext context) async {
      bool isServiceEnabled = await context.read<UserAddressCubit>().checkLocationService(context);
      setState(() {
        _isLocating = true;
        _isEditing = true;
      });

      context.read<UserAddressCubit>().getCurrentLocation(context);
    }

    void _toggleEditMode() {
      setState(() {
        _isEditing = !_isEditing;
        if (!_isEditing) {
          final currentUser = UserDataManager.getUserModel();
          _cityController.text = currentUser?.city ?? '';
          _streetController.text = currentUser?.street ?? '';
          _countryController.text = currentUser?.country ?? 'Lebanon';
        }
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('address'.tr(),
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
                  onPressed: _isSaving || _isLocating ? null : _toggleEditMode,
                  tooltip: _isEditing ? 'cancel'.tr() : 'edit'.tr(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _isEditing ? _buildSaveButton(context) : null,
        body: MultiBlocListener(
          listeners: [
            BlocListener<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is UpdateProfileSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('addressUpdatedSuccessfully'.tr(),
                          style: const TextStyle(color: Colors.black)),
                      backgroundColor: Theme.of(context).primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    _isEditing = false;
                    _isSaving = false;
                  });
                  Navigator.pop(context);
                } else if (state is UpdateProfileErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    _isSaving = false;
                  });
                }
              },
            ),
            BlocListener<UserAddressCubit, UserAddressState>(
              listener: (context, state) {
                if (state is UserLocationLoading) {
                } else if (state is UserLocationDetected) {
                  _cityController.text = state.city;
                  _streetController.text = state.street;
                  _countryController.text = state.country;
                  setState(() {
                    _isLocating = false;
                    _isEditing = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Location detected!'.tr()),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is UserAddressSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('addressUpdatedSuccessfully'.tr(),
                          style: const TextStyle(color: Colors.black)),
                      backgroundColor: Theme.of(context).primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    _isEditing = false;
                    _isSaving = false;
                  });
                  Navigator.pop(context);
                } else if (state is AddressError) {
                  setState(() {
                    _isSaving = false;
                    _isLocating = false;
                  });
                }
              },
            ),
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: _isLocating ? 'locating'.tr() : 'press_to_locate'.tr(),
                      child: AnimatedContainer(

                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          color: _isLocating
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _isLocating
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: _isLocating
                              ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                              : [],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _isSaving || _isLocating
                              ? null
                              : () => _getAutoLocation(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _isLocating
                                    ? SizedBox(
                                  key: ValueKey('loading'),
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: textColor,
                                  ),
                                )
                                    : Icon(
                                  key: ValueKey('icon'),
                                  Icons.my_location,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _isLocating ? 0.8 : 1.0,
                                child: Text(
                                  _isLocating ? 'locating'.tr() : 'auto_location'.tr(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
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
                                        icon: Icons.location_on,
                                        label: 'country'.tr(),
                                        controller: _countryController,
                                        enabled: _isEditing,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'countryRequired'.tr();
                                          }
                                          return null;
                                        },
                                      ),
                                      const Divider(height: 24, thickness: 0.5),
                                      _buildEditableInfoRow(
                                        context,
                                        icon: Icons.location_city,
                                        label: 'city'.tr(),
                                        controller: _cityController,
                                        enabled: _isEditing,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'cityRequired'.tr();
                                          }
                                          return null;
                                        },
                                      ),
                                      const Divider(height: 24, thickness: 0.5),
                                      _buildEditableInfoRow(
                                        context,
                                        icon: Icons.streetview,
                                        label: 'street'.tr(),
                                        controller: _streetController,
                                        enabled: _isEditing,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'streetRequired'.tr();
                                          }
                                          return null;
                                        },
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
            ],
          ),
        ),
      );
    }

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
          onPressed: _isSaving || _isLocating ? null : () => _saveChanges(context),
          child: _isSaving
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
              : Text(
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
                    enabled: enabled && !_isSaving && !_isLocating,
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
  }