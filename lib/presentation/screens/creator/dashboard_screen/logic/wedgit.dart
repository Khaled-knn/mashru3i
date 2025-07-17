
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/LocaleKeys.dart';

Future<List<String>?> showPaymentDialog(BuildContext context, {List<String>? initialSelection}) async {
  List<String> normalizeMethods(List<String>? methods) {
    if (methods == null) return [];
    return methods.map((method) {
      if (method.toLowerCase().contains('wish')) return 'wish_money';
      if (method.toLowerCase().contains('cash')) return 'cash_on_delivery';
      if (method.toLowerCase().contains('omt')) return 'omt';
      return method;
    }).toList();
  }

  List<String> selectedMethods = normalizeMethods(initialSelection);

  return await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          debugPrint("Current selected methods: $selectedMethods");
          return AlertDialog(
            title: Text(
              LocaleKeys.choosePaymentGateway.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCheckboxItem(
                    context,
                    title: LocaleKeys.wishMoney.tr(),
                    value: selectedMethods.contains('wish_money'),
                    onChanged: (value) => _handleMethodSelection(
                      'wish_money',
                      value,
                      selectedMethods,
                      setState,
                    ),
                  ),
                  _buildCheckboxItem(
                    context,
                    title: LocaleKeys.cashOnDelivery.tr(),
                    value: selectedMethods.contains('cash_on_delivery'),
                    onChanged: (value) => _handleMethodSelection(
                      'cash_on_delivery',
                      value,
                      selectedMethods,
                      setState,
                    ),
                  ),
                  _buildCheckboxItem(
                    context,
                    title: LocaleKeys.omt.tr(),
                    value: selectedMethods.contains('omt'),
                    onChanged: (value) => _handleMethodSelection(
                      'omt',
                      value,
                      selectedMethods,
                      setState,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _handleConfirmation(
                  context,
                  selectedMethods,
                ),
                child: Text(
                  LocaleKeys.confirm.tr(),
                  style: TextStyle(
                    color: Colors.green[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}// دالة لبناء عنصر CheckboxListTile
Widget _buildCheckboxItem(
    BuildContext context, {
      required String title,
      required bool value,
      required Function(bool?) onChanged,
    }) {
  return CheckboxListTile(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
    value: value,
    onChanged: onChanged,
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
  );
}

// دالة معالجة اختيار/إلغاء اختيار طريقة الدفع
void _handleMethodSelection(
    String method,
    bool? value,
    List<String> selectedMethods,
    StateSetter setState,
    ) {
  setState(() {
    if (value == true) {
      if (!selectedMethods.contains(method)) {
        selectedMethods.add(method);
      }
    } else {
      selectedMethods.remove(method);
    }
  });
}
void _handleConfirmation(
    BuildContext context,
    List<String> selectedMethods,
    ) {
  if (selectedMethods.isNotEmpty) {
    Navigator.pop(context, selectedMethods);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.selectAtLeastOneMethod.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}