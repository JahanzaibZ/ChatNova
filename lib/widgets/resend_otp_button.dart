import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/auth_provider.dart';
import 'custom_dialog.dart';

class ResendOtpButton extends StatefulWidget {
  final bool isAuthenticated;

  const ResendOtpButton({required this.isAuthenticated, super.key});

  @override
  State<ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  var _remainingSeconds = 30;
  // Timer? _timer;

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !widget.isAuthenticated) {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
    super.initState();
  }

  Future<void> _resendOtp(int resendToken) async {
    try {
      setState(() {
        _remainingSeconds = -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Resending OTP...'),
        ),
      );
      await Provider.of<AuthProvider>(context, listen: false)
          .sendOTP(resendToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('OTP Resent!'),
          ),
        );
      }
      _remainingSeconds = 30;
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      showCustomDialog(
        context,
        title: 'Error Occured!',
        content: '${error.message}\nError code: ${error.code}',
        showActionButton: true,
      );
      setState(() {
        _remainingSeconds = 0;
      });
    } catch (error) {
      Navigator.of(context).pop();
      showCustomDialog(
        context,
        title: 'Unknown Error!',
        content: error.toString(),
        showActionButton: true,
      );
      setState(() {
        _remainingSeconds = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resendToken =
        Provider.of<AuthProvider>(context).otpCredentials['resendToken'] as int;
    return TextButton(
      onPressed: _remainingSeconds != 0 ? null : () => _resendOtp(resendToken),
      child: Text(
        _remainingSeconds > 0
            ? 'Resend OTP ($_remainingSeconds)'
            : 'Resend OTP',
      ),
    );
  }
}
