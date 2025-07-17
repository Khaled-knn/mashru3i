import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mashrou3i/core/helper/user_data_manager.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';

import '../../../../../core/network/remote/dio.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';

class UserHelpCenterScreen extends StatefulWidget {
  const UserHelpCenterScreen({super.key});
  @override
  State<UserHelpCenterScreen> createState() => _UserHelpCenterScreenState();
}


class _UserHelpCenterScreenState extends State<UserHelpCenterScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _showSuccess = false;
  String? _errorMessage;

  Future<void> _sendData() async {
    final String message = _messageController.text.trim();


    setState(() {
      _isLoading = true;
      _showSuccess = false;
      _errorMessage = null;
    });

    try {
      String token = CacheHelper.getData(key: 'userToken');
      final response = await DioHelper.postData(
        url: '/api/help/requests',
        data: {
          'message': message,
        },
        token: "Bearer $token",
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        setState(() {
          _showSuccess = true;
          _messageController.clear();
        });
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to send message. Please try again.';
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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children:
            [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'help_center_title'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
              Image(
                image: AssetImage('assets/images/help.gif'),
                width: 300,
              ),
              Text(
                'help_center_subtitle'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20
                ),
                child: Text(
                  'help_center_description'.tr(),
                  style: TextStyle(
                      fontSize: 12
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CustomFormInput(
                controller: _messageController,
                label: 'write_here_label'.tr(),
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Message cannot be empty'.tr();
                  }
                  return null;
                },
                borderRadius: 10,
                maxLines: 3,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_errorMessage != null) // عرض رسالة الخطأ
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_showSuccess)
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(1),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, -0.5),
                            end: Offset(0, 0),
                          ).animate(CurvedAnimation(
                            parent: AlwaysStoppedAnimation(1),
                            curve: Curves.easeOut,
                          )),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'successfully_sent_message'.tr(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _isLoading ? 48 : 150,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: _isLoading ? EdgeInsets.all(12) : EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_isLoading ? 25 : 10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                            : Text(
                          'send_button'.tr(),
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}