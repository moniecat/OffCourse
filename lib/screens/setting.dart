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
            _inputField('Current password', currentCtrl),
            const SizedBox(height: 12),
            _inputField('New password', newCtrl),
            const SizedBox(height: 12),
            _inputField('Confirm new password', confirmCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                _showSnack('Passwords do not match');
                return;
              }
              if (newCtrl.text.length < 6) {
                _showSnack('Password must be at least 6 characters');
                return;
              }

              Navigator.pop(context);

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.email == null) return;

                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentCtrl.text,
                );

                await user.reauthenticateWithCredential(cred);
                await AuthService().changePassword(newCtrl.text);

                if (!mounted) return;
                _showSnack('Password changed successfully!');
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                _showSnack('Error: ${e.message}');
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
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE53935))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This action is permanent and cannot be undone.',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _inputField('Password', passwordCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
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
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                _showSnack('Error: ${e.message}');
              }
            },
            child: Text('Delete',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => _openDrawer(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 24, top: 12),
              child: Icon(Icons.menu, color: Colors.black),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Settings',
              style: GoogleFonts.montserrat(
                  fontSize: 40, fontWeight: FontWeight.w900)),

          const SizedBox(height: 30),

          /// Preferences
          _SettingSection(title: 'Preferences', children: [
            _ToggleTile(
              label: 'Notifications',
              value: _notifications,
              activeColor: themeYellow,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            const Divider(),
            _ToggleTile(
              label: 'Dark Mode',
              value: _darkMode,
              activeColor: themeYellow,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
          ]),

          const SizedBox(height: 25),

          /// Language (FIXED)
          _SettingSection(
            title: 'Language',
            children: [
RadioGroup<String>(
  groupValue: _language, // ✅ correct param
  onChanged: (value) {
    if (value != null) {
      setState(() => _language = value); // ✅ fix null issue
    }
  },
  child: Column(
    children: [
      RadioListTile<String>(
        title: Text('English',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700)),
        value: 'English',
      ),
      const Divider(),
      RadioListTile<String>(
        title: Text('Filipino',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700)),
        value: 'Filipino',
      ),
    ],
  ),
)
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
            const Divider(),
            _ActionTile(
              label: 'Delete Account',
              icon: Icons.delete_outline,
              color: Colors.red,
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
        Text(title.toUpperCase(),
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
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
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
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
      leading: Icon(icon, color: color),
      title: Text(label,
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}