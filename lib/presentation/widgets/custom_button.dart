import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFilled;
  final double width;
  final Color? color;
  final Color? textColor;
  final double? height;
  final bool isLoading;
  final double ? radios;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFilled = true,
    this.width = double.infinity,
    this.color,
    this.textColor,
    this.height,
    this.isLoading = false, SizedBox? trailing,
    this.radios= 25,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color fillColor = color ?? (isFilled ? theme.colorScheme.primary : Colors.white);
    final Color fontColor = textColor ??
        (isFilled ? theme.colorScheme.onPrimary : theme.colorScheme.primary);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: fillColor,
      foregroundColor: fontColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radios!),
      ),
      elevation: isFilled ? 2 : 0,
    );

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(fontColor),
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: fontColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fontColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}