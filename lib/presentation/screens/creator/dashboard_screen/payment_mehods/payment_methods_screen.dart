import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد easy_localization
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/payment_mehods/payment_mehods_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/payment_mehods/payment_methods_states.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../data/models/payment_method_model.dart';
import '../../../../../core/theme/LocaleKeys.dart'; // تأكد من المسار الصحيح لملف LocaleKeys
import '../../../../widgets/custom_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final Map<String, String> _methodImagePaths = {
    'wishmoney': 'assets/images/whish.png',
    'omt': 'assets/images/omt.png',
    'cash_on_delivery': 'assets/images/cash.png',
  };

  final Map<String, String> _methodDisplayNames = {
    'wishmoney': 'Wish Money',
    'omt': 'OMT',
    'cash_on_delivery': LocaleKeys.cashOnDelivery.tr(),
  };

  final Map<String, IconData> _methodIcons = {
    'wishmoney': Icons.account_balance_wallet,
    'omt': Icons.money,
    'cash_on_delivery': Icons.local_shipping,
  };

  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _selectedMethods = {};
  bool _isSubmitting = false;

  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentMethodsCubit>().fetchPaymentMethods();
    });
  }

  void toggleSelection(String method) {
    setState(() {
      if (_selectedMethods.contains(method)) {
        _selectedMethods.remove(method);
      } else {
        _selectedMethods.add(method);
        _controllers[method] ??= TextEditingController();
      }
    });
  }

  Future<void> _save() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final List<PaymentMethod> selected = _selectedMethods.map((method) {
      final controller = _controllers[method];
      final accountInfo = (method == 'wishmoney' || method == 'omt')
          ? (controller?.text.trim().isEmpty ?? true ? null : controller!.text.trim())
          : null;

      return PaymentMethod(
        method: method,
        accountInfo: accountInfo,
      );
    }).toList();

    try {
      await context.read<PaymentMethodsCubit>().savePaymentMethods(selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.paymentMethodsSavedSuccessfully.tr(), style: TextStyle(color: Colors.black),),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${LocaleKeys.failedToSavePaymentMethods.tr()}: $e'),
              backgroundColor: Colors.red,

          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildMethodItem(String method, bool isSelected) {
    final primaryColor = Theme.of(context).primaryColor;
    final borderColor = isSelected
        ? Color.alphaBlend(primaryColor.withAlpha(128), Colors.white)
        : Colors.grey.withAlpha(51); // 20% opacity of grey

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => toggleSelection(method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_methodImagePaths.containsKey(method))
                    Image.asset(
                      _methodImagePaths[method]!,
                      width: 80,
                      height: 80,
                    )
                  else
                    Icon(
                      _methodIcons[method],
                      color: isSelected ? primaryColor : Colors.grey,
                      size: 40,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _methodDisplayNames[method] ?? method,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black: Colors.grey,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(method),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return primaryColor;
                        }
                        return Colors.white;
                      }),
                    ),
                  ),
                ],
              ),
              if ((method == 'wishmoney' || method == 'omt') && isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 36),
                  child: TextField(
                    controller: _controllers[method],
                    decoration: InputDecoration(
                      labelText: LocaleKeys.accountNumber.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: TextStyle(fontSize: 15),
                      prefixIcon: Icon(Icons.call , size: 15,),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPaymentMethods,
            child: Text(LocaleKeys.retry.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<PaymentMethod> methods) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          LocaleKeys.selectPaymentMethods.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _methodDisplayNames.keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final method = _methodDisplayNames.keys.elementAt(index);
              return _buildMethodItem(
                method,
                _selectedMethods.contains(method),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: LocaleKeys.saveChanges.tr(),
          onPressed: _save,
          isLoading: _isSubmitting,
          textColor: Colors.black,
          radios: 10,

        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.paymentMethods.tr(), style: TextStyle(fontSize: 18),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: popButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
          listener: (context, state) {
            if (state is PaymentMethodsLoaded && !_isDataInitialized) {
              for (var method in state.methods) {
                _selectedMethods.add(method.method);
                _controllers[method.method] =
                    TextEditingController(text: method.accountInfo);
              }
              _isDataInitialized = true;
            }
          },
          builder: (context, state) {
            if (state is PaymentMethodsLoading && !_isDataInitialized) {
              return _buildLoadingState();
            } else if (state is PaymentMethodsError && !_isDataInitialized) {
              return _buildErrorState(state.message);
            } else if (state is PaymentMethodsLoaded || _isDataInitialized) {
              return Stack(
                children: [
                  _buildContent(state is PaymentMethodsLoaded ? state.methods : []),
                ],
              );
            }
            return const SizedBox();
          },
        )
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}