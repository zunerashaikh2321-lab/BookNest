import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _api = ApiClient();

  bool _loading = false;
  bool _otpSent = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_email.text.contains('@')) {
      _message('Enter a valid email address.');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await _api.forgotPassword(
        email: _email.text,
      );
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      final otp = data['otp']?.toString() ?? '';
      setState(() => _otpSent = true);
      if (mounted) {
        _message('OTP: $otp  (demo OTP returned by Apps Script)');
      }
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    if (_otp.text.length != 6) {
      _message('Enter the 6-digit OTP.');
      return;
    }
    if (_password.text.length < 6) {
      _message('New password must contain at least 6 characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      _message('Passwords do not match.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.resetPassword(
        email: _email.text,
        otp: _otp.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      _message('Password reset successfully.');
      Navigator.pop(context);
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.blackKite,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot your password?',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 29,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will generate a one-time code for your registered email.',
              style: TextStyle(color: AppColors.ashes, height: 1.45),
            ),
            const SizedBox(height: 30),
            InputField(
              label: 'Email Address',
              hintText: 'Registered email',
              prefixIcon: Icons.email_outlined,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            GoldButton(
              text: 'Generate OTP',
              onPressed: _sendOtp,
              isLoading: _loading,
            ),
            if (_otpSent) ...[
              const SizedBox(height: 28),
              InputField(
                label: 'OTP',
                hintText: 'Enter 6-digit OTP',
                prefixIcon: Icons.verified_outlined,
                controller: _otp,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'New Password',
                hintText: 'Create new password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _password,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.ashes,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Confirm Password',
                hintText: 'Re-enter new password',
                prefixIcon: Icons.lock_reset_outlined,
                controller: _confirm,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.ashes,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              GoldButton(
                text: 'Reset Password',
                onPressed: _reset,
                isLoading: _loading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
