import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/network/local/cach_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _glowAnimation;

  bool _moveCircles = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _moveCircles = true;
      });
    });
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final String? token = CacheHelper.getData(key: 'token');
    final bool? approved = CacheHelper.getData(key: 'approved');
    final String? userToken = CacheHelper.getData(key: 'userToken');

    if (userToken !=null){
      context.go('/UserLayout');
    }
    else if (token != null) {
      if(approved==true){
        context.go('/DashBoardScreen');
      }else{
        context.go('/PendingApprovalScreen');
      }

    } else {
      context.go('/choose');
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _glowAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
      end: Theme.of(context).colorScheme.primary,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: _moveCircles ? -80 : -130,
            right: _moveCircles ? -80 : -130,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(119, 247, 211, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            bottom: _moveCircles ? -200 : -250,
            left: _moveCircles ? -200 : -250,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(119, 247, 211, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Image.asset(
                        'assets/images/logo.png',
                        width: 280,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}