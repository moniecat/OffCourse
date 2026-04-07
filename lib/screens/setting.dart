import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notifications = true;
  bool _darkMode = false;
  String _language = 'English';

  final Color themeYellow = const Color(0xFFFFB82E);

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        pageBuilder: (_, _, _) => const MenuDrawer(),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Password',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current password',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New password',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              if (newCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              Navigator.pop(context);
              try {
                // Re-authenticate first, then change password
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) return;
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentCtrl.text,
                );
                await user.reauthenticateWithCredential(cred);
                await AuthService().changePassword(newCtrl.text);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully!')),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }
            },
            child: Text('Save',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800, color: const Color(0xFFE53935))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This action is permanent and cannot be undone. Enter your password to confirm.',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) return;
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordCtrl.text,
                );
                await user.reauthenticateWithCredential(cred);
                await AuthService().deleteAccount();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }
            },
            child: Text('Delete',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800, color: const Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () => _openDrawer(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 24, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            'Settings',
            style: GoogleFonts.montserrat(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),

          /// Preferences
          _SettingSection(title: 'Preferences', children: [
            _ToggleTile(
              label: 'Notifications',
              value: _notifications,
              activeColor: themeYellow,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            const Divider(color: Colors.black, thickness: 2, height: 0),
            _ToggleTile(
              label: 'Dark Mode',
              value: _darkMode,
              activeColor: themeYellow,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
          ]),

          const SizedBox(height: 25),

          /// Language — uses standard Flutter RadioListTile (no RadioGroup needed)
          _SettingSection(
            title: 'Language',
            children: [
              RadioListTile<String>(
                title: Text('English',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                value: 'English',
                groupValue: _language,
                activeColor: Colors.black,
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
              const Divider(color: Colors.black, thickness: 2, height: 0),
              RadioListTile<String>(
                title: Text('Filipino',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                value: 'Filipino',
                groupValue: _language,
                activeColor: Colors.black,
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          /// Account
          _SettingSection(title: 'Account', children: [
            _ActionTile(
              label: 'Change Password',
              icon: Icons.lock_outline,
              onTap: _showChangePasswordDialog,
            ),
            const Divider(color: Colors.black, thickness: 2, height: 0),
            _ActionTile(
              label: 'Delete Account',
              icon: Icons.delete_outline,
              color: const Color(0xFFE53935),
              onTap: _showDeleteAccountDialog,
            ),
          ]),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(4, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
      value: value,
      activeThumbColor: activeColor,
      activeTrackColor: activeColor.withValues(alpha: 0.5),
      onChanged: onChanged,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    this.color = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(label,
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700, fontSize: 16, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          color: Colors.black, size: 18),
      onTap: onTap,
    );
  }
}
