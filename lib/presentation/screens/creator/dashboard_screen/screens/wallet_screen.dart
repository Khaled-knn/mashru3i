import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../widgets/compnents.dart'; // Ensure this file exists and contains popButton
import '../logic/dashboard_cibit.dart';
import '../logic/dashboard_states.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController(); // kept for compatibility if needed
  final _formKey = GlobalKey<FormState>();

  // Controllers for converter
  final TextEditingController _tokensController = TextEditingController(text: '');
  double _convertedUsd = 0.0;
  double _appliedRate = 1.0;

  @override
  void initState() {
    super.initState();
    context.read<DashBoardCubit>().getProfileData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tokensController.dispose();
    super.dispose();
  }

  // ====== Unified black decoration for all TextFields ======
  InputDecoration _blackBorderDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black),
      prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
    );
  }

  // ====== PRICING LOGIC (tiers) ======
  // 1   -> $1.00
  // 50+ -> $0.97
  // 500+ -> $0.90
  // 1000+ -> $0.90
  // 5000+ -> $0.85
  double _unitPriceForTokens(double tokens) {
    if (tokens >= 5000) return 0.85;
    if (tokens >= 1000) return 0.90;
    if (tokens >= 500)  return 0.90;
    if (tokens >= 50)   return 0.97;
    return 1.00;
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));

  void _recalcConverter() {
    final t = double.tryParse(_tokensController.text.trim()) ?? 0.0;
    final rate = _unitPriceForTokens(t);
    setState(() {
      _appliedRate = rate;
      _convertedUsd = _round2(t * rate);
    });
  }

  // ====== REQUEST TOKENS DIALOG (enter tokens -> auto USD) ======
  void _showRequestTokensDialog(BuildContext context) {
    final tokensInputCtrl = TextEditingController();
    double localUsd = 0.0;
    double localRate = 1.0;

    void localRecalc(void Function(void Function()) setStateDialog) {
      final t = double.tryParse(tokensInputCtrl.text.trim()) ?? 0.0;
      final r = _unitPriceForTokens(t);
      setStateDialog(() {
        localRate = r;
        localUsd = _round2(t * r);
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                LocaleKeys.request_tokens.tr(),
                style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tokens input (BLACK theme)
                    TextFormField(
                      controller: tokensInputCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _blackBorderDecoration(
                        label: LocaleKeys.coins.tr(),
                        hint: 'e.g., 50',
                        icon: Icons.monetization_on_outlined,
                      ),
                      onChanged: (_) => localRecalc(setStateDialog),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.amount_required.tr();
                        }
                        final t = double.tryParse(value);
                        if (t == null || t <= 0) {
                          return LocaleKeys.enter_valid_positive_amount.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // USD readonly (BLACK theme)
                    TextFormField(
                      enabled: false,
                      decoration: _blackBorderDecoration(
                        label: 'USD',
                        icon: Icons.attach_money,
                      ),
                      controller: TextEditingController(text: localUsd.toStringAsFixed(2)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rate: \$${localRate.toStringAsFixed(2)} / token'
                            '${localRate < 1 ? '  (${((1 - localRate) * 100).toStringAsFixed(0)}% off)' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // نرسل الطلب بقيمة USD المحسوبة
                      Navigator.of(dialogContext).pop();
                      FocusScope.of(context).unfocus();
                      context.read<DashBoardCubit>().requestTokens(localUsd);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(LocaleKeys.send_request.tr(), style: const TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashBoardCubit, DashBoardStates>(
      listener: (context, state) {
        if (state is RequestTokensLoadingState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  // ننخلي النص أسود
                ],
              ),
              duration: const Duration(minutes: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleKeys.sending_request.tr(), style: const TextStyle(color: Colors.black)),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        } else if (state is RequestTokensSuccessState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.black)),
              backgroundColor: Theme.of(context).primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          // حدّث البروفايل بعد الطلب
          context.read<DashBoardCubit>().getProfileData();
        } else if (state is RequestTokensErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<DashBoardCubit>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: true,
            leading: popButton(context),
            title: Text(LocaleKeys.wallet.tr()),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.your_current_balance.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${cubit.creatorProfile?.tokens?.toStringAsFixed(2) ?? '0.00'} ${LocaleKeys.coins.tr()}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Image(
                            image: AssetImage('assets/images/coin.png'),
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ====== Converter Card (Tokens -> USD) ======
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Convert Tokens to USD', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tokensController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _blackBorderDecoration(
                                label: LocaleKeys.coins.tr(),
                                hint: 'e.g., 50',
                                icon: Icons.monetization_on_outlined,
                              ),
                              onChanged: (_) => _recalcConverter(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              enabled: false,
                              decoration: _blackBorderDecoration(
                                label: 'USD',
                                icon: Icons.attach_money,
                              ),
                              controller: TextEditingController(
                                text: _convertedUsd.toStringAsFixed(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [50, 100, 500, 1000, 5000].map((v) {
                          return ActionChip(
                            label: Text(
                              '$v',
                              style: const TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              _tokensController.text = '$v';
                              _recalcConverter();
                            },
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rate: \$${_appliedRate.toStringAsFixed(2)} / token'
                            '${_appliedRate < 1 ? '  (${((1 - _appliedRate) * 100).toStringAsFixed(0)}% off)' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Request tokens using dialog (now token-based input)
                ElevatedButton.icon(
                  onPressed: () => _showRequestTokensDialog(context),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                  label: Text(LocaleKeys.request_tokens.tr(), style: const TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                buildPaymentMethods(context),




              ],
            ),
          ),
        );
      },
    );
  }



  Widget buildPaymentMethods(BuildContext context) {
    final paymentMethods = [
      {
        "name": "Pay W2W",
        "number": "+961 70 044 990",
        "image": "assets/images/whish.png",
      },
      {
        "name": "Pay OMT",
        "number": "+961 78 874 707",
        "image": "assets/images/omt.png",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paymentMethods.map((method) {
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Image.asset(
                method["image"] as String,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              title: Text(
                method["name"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                method["number"] as String,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: method["number"] as String));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text("${method["name"]} number copied!" , style: TextStyle(color: Colors.black),),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }


}
