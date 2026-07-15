import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';
import 'package:vincly/core/theme/context_extension.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isSending = false;
  bool _isChecking = false;

  void _resendEmail() async {
    setState(() => _isSending = true);
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.email_verification.msg_sent'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending email: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _checkVerified() async {
    setState(() => _isChecking = true);
    try {
      await _authService.reloadUser();
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bağlantı Hatası: $e')));
        return;
      }
    }

    if (mounted) {
      setState(() => _isChecking = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auth.email_verification.title'.tr()),
        centerTitle: true,
        backgroundColor: context.colors.bgWhite,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: context.colors.secondaryPeach,
              ),
              const SizedBox(height: 32),
              Text(
                'auth.email_verification.headline'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'auth.email_verification.description'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: context.colors.textLight),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkVerified,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.check_circle_outline),
                label: Text(
                  'auth.email_verification.button_verify'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.colors.primaryPink,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _isSending ? null : _resendEmail,
                icon: _isSending
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: context.colors.secondaryPeach,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.mail_outline,
                        color: context.colors.secondaryPeach,
                      ),
                label: Text(
                  'auth.email_verification.button_resend'.tr(),
                  style: TextStyle(color: context.colors.secondaryPeach),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  _authService.signOut();
                  
                },
                child: Text(
                  'auth.email_verification.button_logout'.tr(),
                  style: TextStyle(color: context.colors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
