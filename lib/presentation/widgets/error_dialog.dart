import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.error, color: Colors.red),
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(message),
      ),
      actions: actions,
    );
  }
}