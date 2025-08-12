import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../widgets/coustem_form_input.dart';

class UserHelpCenterScreen extends StatefulWidget {
  const UserHelpCenterScreen({super.key});

  @override
  State<UserHelpCenterScreen> createState() => _UserHelpCenterScreenState();
}

class _UserHelpCenterScreenState extends State<UserHelpCenterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _showSuccess = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  Future<void> _sendData() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _errorMessage = 'Message cannot be empty'.tr();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuccess = false;
      _errorMessage = null;
    });

    try {
      String token = CacheHelper.getData(key: 'userToken');
      final response = await DioHelper.postData(
        url: '/api/help/requests',
        data: {'message': message},
        token: "Bearer $token",
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        setState(() {
          _showSuccess = true;
          _messageController.clear();
        });
        _animationController.forward(from: 0);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _animationController.reverse();
          setState(() {
            _showSuccess = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response.data['message'] ?? 'Failed to send message. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
      print('Error sending help request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'help_center_title'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/images/help.gif', width: 300),
                  const SizedBox(height: 10),
                  Text(
                    'help_center_subtitle'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'help_center_description'.tr(),
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomFormInput(
                    controller: _messageController,
                    label: 'write_here_label'.tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Message cannot be empty'.tr();
                      }
                      return null;
                    },
                    borderRadius: 10,
                    maxLines: 3,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_showSuccess)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                'successfully_sent_message'.tr(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isLoading ? 48 : 150,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: _isLoading
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_isLoading ? 25 : 10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                          : Text(
                        'send_button'.tr(),
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
