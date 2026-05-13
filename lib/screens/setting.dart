import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/theme_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static const double borderWidth = 3.0;
  final Color themeYellow = const Color(0xFFFFB82E);
  final Color themeTeal = const Color(0xFF2ABB9B);
  String _userRole = 'student';

  bool get _isAdmin => _userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      final doc = await FirestoreService().getUser(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _userRole = data['role'] ?? 'student';
        });
      }
    } catch (_) {}
  }

  // --- Header Helpers ---

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      pageBuilder: (_, __, ___) => MenuDrawer(isAdmin: _isAdmin, currentScreen: 'Setting'),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
          child: child,
        );
      },
    ));
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _openDrawer(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: borderWidth),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(3, 3))],
        ),
        child: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface, size: 30),
      ),
    );
  }

  // --- Actions ---

  Future<void> _sendEmail({required String subject, required String body}) async {
    final user = FirebaseAuth.instance.currentUser;
    final String fullBody = "$body\n\n---\nUser ID: ${user?.uid ?? 'Not Logged In'}\nEmail: ${user?.email ?? 'N/A'}";
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '22104852@usc.edu.ph',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(fullBody)}',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        _showSnack('Could not open email app.');
      }
    } catch (e) { _showSnack('Error: $e'); }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Dialogs ---

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Change\nPassword",
                  style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w900, height: 1.1, color: Colors.black)),
              const SizedBox(height: 35),
              _buildDialogField("Current Password", Icons.lock_outline, currentCtrl),
              const SizedBox(height: 15),
              _buildDialogField("New Password", Icons.vpn_key_outlined, newCtrl),
              const SizedBox(height: 15),
              _buildDialogField("Confirm Password", Icons.check_circle_outline, confirmCtrl),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(child: _buildDialogButton("Cancel", Colors.white, const Color(0xFF9E9E9E), () => Navigator.pop(context))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDialogButton("Save", themeTeal, Colors.white, () async {
                    if (newCtrl.text != confirmCtrl.text) { _showSnack('Passwords do not match'); return; }
                    Navigator.pop(context);
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      final cred = EmailAuthProvider.credential(email: user!.email!, password: currentCtrl.text);
                      await user.reauthenticateWithCredential(cred);
                      await AuthService().changePassword(newCtrl.text);
                      _showSnack('Password changed successfully!');
                    } catch (e) { _showSnack('Error: Incorrect password.'); }
                  })),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.black, width: 3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Delete\nAccount", style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w900, height: 1.1, color: Colors.red)),
              const SizedBox(height: 15),
              Text("This action is permanent.", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 25),
              _buildDialogField("Enter Password", Icons.lock_outline, passwordCtrl),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(child: _buildDialogButton("Cancel", Colors.white, const Color(0xFF9E9E9E), () => Navigator.pop(context))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDialogButton("Delete", Colors.red, Colors.white, () async {
                    Navigator.pop(context);
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      final cred = EmailAuthProvider.credential(email: user!.email!, password: passwordCtrl.text);
                      await user.reauthenticateWithCredential(cred);
                      await AuthService().deleteAccount();
                    } catch (e) { _showSnack('Auth failed.'); }
                  })),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E), size: 22),
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: const Color(0xFF9E9E9E)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.black, width: 2)),
      ),
    );
  }

  Widget _buildDialogButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: bgColor != Colors.white ? [const BoxShadow(color: Colors.black, offset: Offset(0, 4))] : null,
        ),
        child: Center(child: Text(text, style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w900, fontSize: 20))),
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // FIX: Removed underscores from local variable names to comply with Dart linting
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent, 
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25, top: 10),
            child: _buildMenuButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _SettingSection(title: 'Preferences', children: [
                    Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
                      return _ToggleTile(label: 'Dark Mode', value: themeProvider.isDarkMode, activeColor: themeYellow, onChanged: (v) => themeProvider.setTheme(v));
                    }),
                    const Divider(height: 1, thickness: 1),
                    _ActionTile(label: 'Language', icon: Icons.language, trailingText: 'English', onTap: () => _showSnack('Only English is supported.')),
                  ]),
                  const SizedBox(height: 25),
                  _SettingSection(title: 'Support', children: [
                    _ActionTile(label: 'Report a Bug', icon: Icons.bug_report_outlined, onTap: () => _sendEmail(subject: '[BUG REPORT]', body: 'Describe bug:')),
                    const Divider(height: 1, thickness: 1),
                    _ActionTile(label: 'Feature Request', icon: Icons.lightbulb_outline, onTap: () => _sendEmail(subject: '[FEATURE REQUEST]', body: 'Describe feature:')),
                  ]),
                  const SizedBox(height: 25),
                  _SettingSection(title: 'Account & Storage', children: [
                    _ActionTile(label: 'Change Password', icon: Icons.lock_outline, onTap: _showChangePasswordDialog),
                    const Divider(height: 1, thickness: 1),
                    _ActionTile(label: 'Delete Account', icon: Icons.delete_outline, color: Colors.red, onTap: _showDeleteAccountDialog),
                  ]),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Internal Widgets ---

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 13, color: textColor.withValues(alpha: 0.5))),
      const SizedBox(height: 10),
      Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(width: 3.0, color: textColor), borderRadius: BorderRadius.circular(12)), child: Column(children: children)),
    ]);
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label, required this.value, required this.activeColor, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(title: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)), value: value, activeThumbColor: activeColor, activeTrackColor: activeColor.withValues(alpha: 0.5), onChanged: onChanged);
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final String? trailingText;
  const _ActionTile({required this.label, required this.icon, this.color, required this.onTap, this.trailingText});
  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: tileColor)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailingText != null) Text(trailingText!, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, color: tileColor.withValues(alpha: 0.6))),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, size: 16, color: tileColor),
      ]),
      onTap: onTap,
    );
  }
}