import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();
  late final TextEditingController _name;
  late final TextEditingController _birthdate;
  late final TextEditingController _phone;
  late String _gender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = Session.currentUser!;
    _name = TextEditingController(text: u.name);
    _birthdate = TextEditingController(text: u.birthdate);
    _phone = TextEditingController(text: u.phoneNumber);
    _gender = u.gender.isEmpty ? 'Prefer not to say' : u.gender;
  }

  @override
  void dispose() {
    _name.dispose();
    _birthdate.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final u = Session.currentUser!;
    setState(() => _loading = true);
    try {
      await _api.updateProfile(
        userId: u.userId,
        name: _name.text,
        birthdate: _birthdate.text,
        gender: _gender,
        phoneNumber: _phone.text,
        profileImage: u.profileImage,
      );
      final fresh = await _api.getUser(
        userId: u.userId,
      );
      Session.start(fresh);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.blackKite,
          ),
        );
      }
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
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            InputField(
              label: 'Name',
              hintText: 'Your name',
              prefixIcon: Icons.person_outline,
              controller: _name,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Birthdate',
              hintText: 'YYYY-MM-DD',
              prefixIcon: Icons.cake_outlined,
              controller: _birthdate,
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Phone Number',
              hintText: 'Phone number',
              prefixIcon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gender',
              style: TextStyle(
                color: AppColors.white,
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
                  prefixIcon: Icon(Icons.person_2_outlined, color: AppColors.gold),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: AppColors.white),
                items: const [
                  'Female',
                  'Male',
                  'Other',
                  'Prefer not to say',
                ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
            ),
            const SizedBox(height: 24),
            GoldButton(text: 'Save Changes', onPressed: _save, isLoading: _loading),
          ],
        ),
      ),
    );
  }
}
