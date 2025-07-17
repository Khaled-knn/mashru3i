import 'package:flutter/material.dart';

class CustomFormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function? suffixClicked;
  final String? Function(String?)? validator;
  final TextInputType ? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final bool isFilled;
  final Color? borderColor;
  final Color? fillColor;
  final Color? labelColor;
  final double borderRadius;
  final double width;
  final Function? onChanged;
  final Color suffixColor;
  final Function ? onTap;
  final String ?  prefixText;
  final bool   readOnly;
  final double  hintFontSize  ;

  const CustomFormInput({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixClicked,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.isFilled = false,
    this.borderColor = Colors.grey,
    this.fillColor,
    this.labelColor,
    this.borderRadius = 25.0,
    this.width = double.infinity,
    this.onChanged,
    this.suffixColor = Colors.grey,
    this.onTap,
    this.prefixText,
    this.readOnly=false,
    this.hintFontSize = 16 ,

  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderCol = borderColor ?? theme.colorScheme.onSurface;
    final Color backgroundCol =
        fillColor ?? (isFilled ? theme.colorScheme.primary : Colors.white);
    final Color labelCol = labelColor ?? Colors.grey;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundCol,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderCol),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        onChanged: (value) {
          if (onChanged != null) onChanged!();
        },
        onTap: (){
          if (onTap != null) onTap!();
        },
        validator: validator,
        decoration: InputDecoration(
          prefixText: prefixText,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          labelText: label,
          labelStyle: TextStyle(
            color: labelCol,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey , fontSize: hintFontSize),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
            onPressed: () {
              if (suffixClicked != null) suffixClicked!();
            },
            icon: Icon(suffixIcon, color: suffixColor),
          )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
