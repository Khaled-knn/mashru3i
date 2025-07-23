import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<DashBoardCubit>().getProfileData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showRequestTokensDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Cannot be dismissed by tapping outside
      builder: (BuildContext dialogContext) {
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
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: LocaleKeys.amount_in_usd.tr(),
                hintText: 'e.g., 50.0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.amount_required.tr(); // Error message
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return LocaleKeys.enter_valid_positive_amount.tr(); // Error message
                }
                return null;
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround, // Better button distribution
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _amountController.clear();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error, // Red for cancel
              ),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) { // Validate input
                  final double amount = double.parse(_amountController.text.trim());
                  Navigator.of(dialogContext).pop(); // Close input dialog

                  // Show confirmation dialog
                  _showConfirmationDialog(context, amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).primaryColor, // Distinct color for primary button
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(LocaleKeys.send_request.tr() , style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext confirmDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            LocaleKeys.confirm_request.tr(),
            style: Theme.of(confirmDialogContext).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${LocaleKeys.confirm_request_message.tr()} ${_amountController.text}  tokens ?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(confirmDialogContext).pop();
                _amountController.clear();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(confirmDialogContext).colorScheme.error,
              ),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(confirmDialogContext).pop(); // Close confirmation dialog
                FocusScope.of(context).unfocus(); // Hide keyboard

                // Send the actual request via Cubit
                context.read<DashBoardCubit>().requestTokens(amount);
                _amountController.clear(); // Clear the field after sending
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(confirmDialogContext).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(LocaleKeys.confirm.tr() , style: TextStyle(color: Colors.black),),
            ),
          ],
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
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(width: 15),
                  Text(LocaleKeys.sending_request.tr(), style: TextStyle(color: Colors.black)),
                ],
              ),
              duration: const Duration(minutes: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        } else if (state is RequestTokensSuccessState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message , style: TextStyle(color: Colors.black),),
              backgroundColor: Theme.of(context).primaryColor, // Green for success
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is RequestTokensErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red, // Red for error
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increased padding
            child: Column(
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient( // Beautiful gradient
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
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _showRequestTokensDialog(context),
                  icon: const Icon(Icons.add_circle_outline , color: Colors.black,),
                  label: Text(LocaleKeys.request_tokens.tr() , style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5, // Button shadow
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