import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_new.text.length < 6 || _new.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check the new password and confirmation.'),
          backgroundColor: AppColors.blackKite,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.changePassword(
        userId: Session.currentUser!.userId,
        oldPassword: _old.text,
        newPassword: _new.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully.'),
            backgroundColor: AppColors.blackKite,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.blackKite,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        title: const Text('Change Password'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        children: [
          InputField(
            label: 'Current Password',
            hintText: 'Enter current password',
            prefixIcon: Icons.lock_outline,
            controller: _old,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'New Password',
            hintText: 'Enter new password',
            prefixIcon: Icons.lock_reset_outlined,
            controller: _new,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Confirm Password',
            hintText: 'Confirm new password',
            prefixIcon: Icons.verified_user_outlined,
            controller: _confirm,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          GoldButton(
            text: 'Update Password',
            onPressed: _save,
            isLoading: _loading,
          ),
        ],
      ),
    );
  }
}
