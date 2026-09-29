import 'package:flutter/material.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import 'change_password_screen.dart';
import 'contact_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'watched_book_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    setState(() {});
  }

  void _logout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = Session.currentUser!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.blackKite,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.gold,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.ashes, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _group('Account', [
          _item(Icons.person_outline, 'Edit Profile', _edit),
          _item(
            Icons.visibility_outlined,
            'Watched Books',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WatchedBooksScreen()),
            ),
          ),
          _item(
            Icons.lock_outline,
            'Change Password',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        _group('Support', [
          _item(
            Icons.mail_outline,
            'Contact Us',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactScreen()),
            ),
          ),
          _item(Icons.info_outline, 'About BookNest', () => _about()),
        ]),
        const SizedBox(height: 18),
        _group('Session', [
          _item(Icons.logout_rounded, 'Logout', _logout, danger: true),
        ]),
      ],
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.lightCharcoal,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dryadBark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _item(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool danger = false,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: danger ? Colors.redAccent : AppColors.gold,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: danger ? Colors.redAccent : AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.lightCharcoal,
      ),
    );
  }

  void _about() {
    showAboutDialog(
      context: context,
      applicationName: 'BookNest',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.gold,
      ),
      children: const [
        Text(
          'Discover. Read. Belong.\n\nA Flutter + Google Sheets powered book discovery project.',
        ),
      ],
    );
  }
}
