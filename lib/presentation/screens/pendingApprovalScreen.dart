import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/constent/constent.dart';
import '../../core/network/local/cach_helper.dart';
import '../../core/theme/LocaleKeys.dart';
import '../widgets/compnents.dart';
import '../widgets/custom_button.dart';
import 'creator/dashboard_screen/logic/dashboard_cibit.dart';
import 'creator/dashboard_screen/logic/dashboard_states.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _statusTimer;
  late DashBoardCubit _dashBoardCubit;
  bool _isRefreshing = false;
  int _nextCheckInSeconds = 10;

  @override
  void initState() {
    super.initState();
    _dashBoardCubit = context.read<DashBoardCubit>();
    _checkStatusImmediately();
    _startTimerCountdown();
  }

  void _startTimerCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextCheckInSeconds > 0) {
        setState(() => _nextCheckInSeconds--);
      } else {
        setState(() => _nextCheckInSeconds = 10);
      }
    });
  }

  Future<void> _checkStatusImmediately() async {
    setState(() => _isRefreshing = true);
    await _dashBoardCubit.getProfileData();
    setState(() => _isRefreshing = false);
    if (mounted) _startStatusCheckTimer();
  }

  void _startStatusCheckTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _dashBoardCubit.getProfileData();
      }
    });
  }

  Future<void> _manualRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _nextCheckInSeconds = 10;
    });

    try {
      await _dashBoardCubit.getProfileData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _statusTimer = null;
    super.dispose();
  }

  Future<void> _handleProfileStatus(String? status) async {
    if (status == 'approved') {
      if (mounted) {
        _statusTimer?.cancel();
        context.go('/DashBoardScreen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _manualRefresh,
        child: BlocListener<DashBoardCubit, DashBoardStates>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              _handleProfileStatus(state.profile.status);
            } else if (state is ProfileError && mounted) {

            }
          },
          child: Center(child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(),
            const SizedBox(height: 30),
            _buildStatusIndicator(),
            const SizedBox(height: 20),
            _buildThankYouMessage(),
            const SizedBox(height: 10),
            _buildNextCheckText(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSubscriptionButton(context)),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _manualRefresh,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: _isRefreshing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.refresh, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return BlocBuilder<DashBoardCubit, DashBoardStates>(
      builder: (context, state) {
        return Center(
          child: state is ProfileLoading || _isRefreshing
              ? const CircularProgressIndicator()
              : const ApprovedStatusIcon(),
        );
      },
    );
  }

  Widget _buildThankYouMessage() {
    return Column(
      children: [
        Text(
          LocaleKeys.thankYouSignUp.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          LocaleKeys.pending.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNextCheckText() {
    return Text(
      '${LocaleKeys.nextCheckIn.tr()}: $_nextCheckInSeconds ${LocaleKeys.seconds.tr()}',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSubscriptionButton(BuildContext context) {
    return CustomButton(
      color: Colors.black26,
      onPressed: _handleSubscriptionButton,
      text: 'Back',
      icon: Icons.arrow_back_ios_rounded,
      textColor: Theme.of(context).primaryColor,
      radios: 8,
      height: 55,
    );
  }

  void _handleSubscriptionButton() {
    context.go('/choose');
  }
}

class ApprovedStatusIcon extends StatelessWidget {
  const ApprovedStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.done,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const Image(image: AssetImage('assets/images/logo.png') , width: 250,));
  }
}

class PopButton extends StatelessWidget {
  const PopButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }
}