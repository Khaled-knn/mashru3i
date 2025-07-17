import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/LocaleKeys.dart';
import '../../../../widgets/coustem_form_input.dart';

class PortfolioLinksField extends StatefulWidget {
  final int professionId;
  final ValueChanged<List<String>> onChanged;
  final List<String> initialLinks;

  const PortfolioLinksField({
    super.key,
    required this.onChanged,
    this.initialLinks = const [],
    required this.professionId,
  });

  @override
  State<PortfolioLinksField> createState() => _PortfolioLinksFieldState();
}

class _PortfolioLinksFieldState extends State<PortfolioLinksField> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _disposeControllers(); // Dispose existing controllers before re-initializing
    _controllers = widget.initialLinks.map((e) => TextEditingController(text: e)).toList();
    if (_controllers.isEmpty) {
      _controllers.add(TextEditingController());
    }
    _addListenersToControllers();
  }

  void _addListenersToControllers() {
    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _onTextChanged() {
    _notifyParent();
  }

  void _notifyParent() {
    widget.onChanged(
        _controllers.map((e) => e.text.trim()).where((text) => text.isNotEmpty).toList()
    );
  }

  void _addLink() {
    setState(() {
      final newController = TextEditingController();
      newController.addListener(_onTextChanged);
      _controllers.add(newController);
    });
    _notifyParent();
  }

  void _removeLink(int index) {
    setState(() {
      final controllerToRemove = _controllers[index];
      controllerToRemove.removeListener(_onTextChanged);
      controllerToRemove.dispose();
      _controllers.removeAt(index);
      if (_controllers.isEmpty) { // If all links are removed, add one empty input field
        _addLink();
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            _getLinksName(widget.professionId).tr(), // Added .tr()
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        ..._controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: CustomFormInput(
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.required.tr(); // Using localized string
                      }
                      return null;
                    },
                    label: '',
                    hintText: LocaleKeys.portfolioLinkHint.tr(), // Using localized string
                    borderRadius: 10,
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 10),
                if (index == _controllers.length - 1)
                  InkWell(
                    onTap: _addLink,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
                const SizedBox(width: 10),
                if (_controllers.length > 1)
                  InkWell(
                    onTap: () => _removeLink(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.remove, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

String _getLinksName(int professionId) {
  // Using LocaleKeys for labels
  switch (professionId) {
    case 5: // Freelancer
      return LocaleKeys.portfolioLinksLabel;
    case 6:
      return LocaleKeys.driveLink; // Assuming you have a DriveLink key for Tutoring
    default:
      return LocaleKeys.links; // Default generic 'Links' label
  }
}