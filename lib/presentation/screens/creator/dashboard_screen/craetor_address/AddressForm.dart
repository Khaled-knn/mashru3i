import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mashrou3i/core/theme/LocaleKeys.dart'; // تأكد من وجود LocaleKeys.pleaseEnterCorrectAddress
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../data/models/creator_address.dart';
import 'address_cubit.dart';
import 'address_state.dart';
class AddressForm extends StatefulWidget {
  final int? creatorId;
  final String token;

  const AddressForm({required this.creatorId, required this.token, super.key});

  @override
  State<AddressForm> createState() => _AddressFormState();
}
class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _streetFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _countryFocus = FocusNode();

  bool _isInitialLoadHandled = false;

  @override
  void initState() {
    super.initState();
    if (widget.creatorId != null) {
      context.read<AddressCubit>().loadAddress();
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _streetFocus.dispose();
    _cityFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          // تحديث الحقول بناءً على الحالة
          // نستخدم _isInitialLoadHandled للتأكد من أننا نحدث Controllers مرة واحدة فقط عند التحميل الأولي
          if ((state is AddressLoaded || state is LocationDetected) && !_isInitialLoadHandled) {
            _updateControllers(state);
            _isInitialLoadHandled = true; // يتم تحديثها بعد أول تحميل ناجح
          } else if (state is AddressInitial && !_isInitialLoadHandled) {
            // مسح الحقول إذا كانت الحالة Initial ولم يتم التعامل مع التحميل الأولي
            _clearControllers();
            _isInitialLoadHandled = true;
          }


          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isArabic),
                      const SizedBox(height: 32),
                      _buildLocationButton(),
                      const SizedBox(height: 32),
                      _buildAddressForm(isArabic),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
              if (state is AddressLoading ||
                  state is LocationLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: popButton(context),
      title: Text('address'.tr(), style: TextStyle(fontSize: 18),),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            if (widget.creatorId != null) {
              // عند التحديث اليدوي، نعيد تعيين العلم للسماح بتحديث الـ controllers
              _isInitialLoadHandled = false;
              context.read<AddressCubit>().loadAddress();
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 200,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        // **** استخدام LocaleKeys.pleaseEnterCorrectAddress.tr()
        Text(
          LocaleKeys.pleaseEnterCorrectAddress.tr(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return OutlinedButton.icon(
      icon:  Icon(Icons.my_location, size: 24 , color: textColor),
      label: Text(
        'get_current_location'.tr(),
        style: TextStyle(fontSize: 16, color: textColor , fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),

        ),
        side: BorderSide(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      // **** لا يوجد شرط يمنع الضغط هنا، الزر سيعمل دائماً
      onPressed: () {
        // طباعة لتأكيد أن الزر قابل للنقر
        debugPrint('Get current location button pressed!');
        _handleLocationButtonPress();
      },
    );
  }

  Future<void> _handleLocationButtonPress() async {
    final cubit = context.read<AddressCubit>();
    final state = cubit.state;

    if (state is AddressError) {
      if (state.type == ErrorType.locationDisabled) {
        await _showEnableLocationDialog();
      } else if (state.type == ErrorType.permissionDenied ||
          state.type == ErrorType.permissionPermanentlyDenied) {
        await _showLocationPermissionDialog();
      } else {
        // إذا كان خطأ آخر غير متعلق بالموقع، لا نمنع استدعاء getCurrentLocation
        cubit.getCurrentLocation();
      }
    } else {
      cubit.getCurrentLocation();
    }
  }

  Future<void> _showEnableLocationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('location_service_disabled'.tr(), style: TextStyle(
            fontSize: 20
        ),),
        content: Text('enable_location_message'.tr()),
        actions: [
          TextButton(
            child: Text('cancel'.tr(), style: TextStyle(color: Colors.red[900]),),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('settings'.tr(), style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),),
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<AddressCubit>().getCurrentLocation();
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('location_permission_required'.tr()),
        content: Text('enable_location_permission_message'.tr()),
        actions: [
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('settings'.tr()),
            onPressed: () async {
              await Geolocator.openAppSettings();
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<AddressCubit>().getCurrentLocation();
    }
  }

  Widget _buildAddressForm(bool isArabic) {
    return Column(
      children: [
        _buildTextField(
          controller: _streetController,
          focusNode: _streetFocus,
          nextFocus: _cityFocus,
          label: 'street'.tr(),
          icon: Icons.streetview,
          isArabic: isArabic,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _cityController,
          focusNode: _cityFocus,
          nextFocus: _countryFocus,
          label: 'city'.tr(),
          icon: Icons.location_city,
          isArabic: isArabic,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _countryController,
          focusNode: _countryFocus,
          label: 'country'.tr(),
          icon: Icons.map,
          isLast: true,
          isArabic: isArabic,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required IconData icon,
    bool isLast = false,
    required bool isArabic,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder( // تحسين: إضافة Focused Border
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder( // تحسين: إضافة Error Border
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder( // تحسين: إضافة Focused Error Border
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'field_required'.tr() : null,
      onFieldSubmitted: (_) {
        if (!isLast && nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          _saveAddress();
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveAddress,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        'save_address'.tr(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, AddressState state) {
    if (state is AddressError) {
      if (state.type == ErrorType.locationDisabled) {
        _showEnableLocationDialog();
      } else if (state.type == ErrorType.permissionDenied ||
          state.type == ErrorType.permissionPermanentlyDenied) {
        _showLocationPermissionDialog();
      } else if (state.type == ErrorType.notFound) {
        // **** لا تعرض SnackBar لهذا النوع من الأخطاء في هذا السياق
        debugPrint('Address not found, form remains empty or populated from location.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (state is AddressSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'address_saved'.tr() , style: TextStyle(color: Colors.black)),
          backgroundColor:Theme.of(context).primaryColor,
        ),
      );
      Navigator.pop(context);
    } else if (state is LocationDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.locationFetched.tr(), style: TextStyle(color: Colors.black),),
          backgroundColor:Theme.of(context).primaryColor,
        ),
      );
      _updateControllers(state);
    }
  }

  void _updateControllers(AddressState state) {
    AddressModel? address;
    if (state is AddressLoaded) {
      address = state.address;
    } else if (state is LocationDetected) {
      address = state.address;
    }
    _streetController.text = address?.street ?? '';
    _cityController.text = address?.city ?? '';
    _countryController.text = address?.country ?? '';
  }

  void _clearControllers() {
    _streetController.clear();
    _cityController.clear();
    _countryController.clear();
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() != true) return;

    if (widget.creatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('creator_id_missing'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newAddress = AddressModel(
      creatorId: widget.creatorId!,
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
    );

    context.read<AddressCubit>().saveAddress(newAddress);
  }
}