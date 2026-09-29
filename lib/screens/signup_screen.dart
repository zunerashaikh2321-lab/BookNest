import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birthdate = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _api = ApiClient();

  String _gender = 'Prefer not to say';
  bool _terms = false;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    for (final c in [
      _name, _birthdate, _email, _phone, _password, _confirm
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_terms) {
      _message('Please accept the Terms & Conditions.');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await _api.signup(
        name: _name.text,
        birthdate: _birthdate.text,
        gender: _gender,
        email: _email.text,
        password: _password.text,
        phoneNumber: _phone.text,
        termsAccepted: true,
      );
      Session.start(user);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
      );
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Exception: ', ''));
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
        elevation: 0,
        title: const Text('Create Account'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join BookNest',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Create your account and make your reading list yours.',
                style: TextStyle(color: AppColors.ashes),
              ),
              const SizedBox(height: 28),
              InputField(
                label: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline_rounded,
                controller: _name,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Birthdate',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icons.cake_outlined,
                controller: _birthdate,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gender',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.dryadBark,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _gender,
                  dropdownColor: AppColors.dryadBark,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_2_outlined,
                      color: AppColors.gold,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  items: const [
                    'Female',
                    'Male',
                    'Other',
                    'Prefer not to say',
                  ].map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: Icons.phone_outlined,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Password',
                hintText: 'Create a password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _password,
                obscureText: _obscure,
                validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
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
                hintText: 'Re-enter password',
                prefixIcon: Icons.lock_reset_outlined,
                controller: _confirm,
                obscureText: _obscureConfirm,
                validator: (v) => v != _password.text
                    ? 'Passwords do not match'
                    : null,
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
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _terms,
                activeColor: AppColors.gold,
                checkColor: AppColors.background,
                onChanged: (v) => setState(() => _terms = v ?? false),
                title: const Text(
                  'I agree to the Terms & Conditions',
                  style: TextStyle(color: AppColors.ashes, fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              GoldButton(
                text: 'Create Account',
                onPressed: _signup,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.blackKite,
      ),
    );
  }
}
