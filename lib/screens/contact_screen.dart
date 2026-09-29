import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final u = Session.currentUser!;
    try {
      await _api.contact(
        userId: u.userId,
        name: u.name,
        email: u.email,
        subject: _subject.text,
        message: _message.text,
      );
      _subject.clear();
      _message.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully.'),
            backgroundColor: AppColors.blackKite,
          ),
        );
      }
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
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        children: [
          const Text(
            'We are here to help.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send your question or feedback and it will be saved in BookNest.',
            style: TextStyle(color: AppColors.ashes, height: 1.45),
          ),
          const SizedBox(height: 25),
          InputField(
            label: 'Subject',
            hintText: 'What is this about?',
            prefixIcon: Icons.subject_rounded,
            controller: _subject,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Message',
            hintText: 'Write your message...',
            prefixIcon: Icons.message_outlined,
            controller: _message,
          ),
          const SizedBox(height: 22),
          GoldButton(text: 'Send Message', onPressed: _send, isLoading: _loading),
        ],
      ),
    );
  }
}
