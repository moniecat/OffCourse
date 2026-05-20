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

  // --- Centered Pop-up Helpers ---

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: themeTeal, strokeWidth: 6),
              const SizedBox(height: 25),
              Text(
                "Processing...",
                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog({required String title, required String message, Color? titleColor}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 30, fontWeight: FontWeight.w900, color: titleColor ?? Colors.black)),
                const SizedBox(height: 15),
                Text(message, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
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
      }
    } catch (_) {}
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.black, width: 3)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Change\nPassword", style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 25),
                  _buildDialogField(hint: "Current Password", icon: Icons.lock, controller: currentCtrl, isObscure: obscureCurrent, onToggle: () => setDialogState(() => obscureCurrent = !obscureCurrent)),
                  const SizedBox(height: 15),
                  _buildDialogField(hint: "New Password", icon: Icons.vpn_key, controller: newCtrl, isObscure: obscureNew, onToggle: () => setDialogState(() => obscureNew = !obscureNew)),
                  const SizedBox(height: 15),
                  _buildDialogField(hint: "Confirm Password", icon: Icons.check_circle, controller: confirmCtrl, isObscure: obscureConfirm, onToggle: () => setDialogState(() => obscureConfirm = !obscureConfirm)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: _buildDialogButton("Cancel", Colors.white, Colors.grey, () => Navigator.pop(dialogContext))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildDialogButton("Save", themeTeal, Colors.white, () async {
                        if (newCtrl.text != confirmCtrl.text) {
                          _showMessageDialog(title: "Error", message: "Passwords do not match.", titleColor: Colors.orange);
                          return;
                        }
                        
                        // Capture Navigator before async
                        final navigator = Navigator.of(context);
                        
                        Navigator.pop(dialogContext); // Close the input dialog
                        _showLoadingDialog();
                        
                        try {
                          final user = FirebaseAuth.instance.currentUser!;
                          final cred = EmailAuthProvider.credential(email: user.email!, password: currentCtrl.text);
                          await user.reauthenticateWithCredential(cred);
                          await AuthService().changePassword(newCtrl.text);
                          
                          if (!mounted) return;
                          navigator.pop(); // Remove loading dialog using captured navigator
                          _showMessageDialog(title: "Success", message: "Password updated!", titleColor: themeTeal);
                        } catch (e) {
                          if (!mounted) return;
                          navigator.pop(); // Remove loading dialog using captured navigator
                          _showMessageDialog(title: "Error", message: "Authentication failed.", titleColor: Colors.red);
                        }
                      })),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();
    bool obscurePass = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.black, width: 3)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delete\nAccount", style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.red)),
                const SizedBox(height: 10),
                Text("This is permanent. Re-enter password to confirm.", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                const SizedBox(height: 25),
                _buildDialogField(hint: "Password", icon: Icons.lock, controller: passwordCtrl, isObscure: obscurePass, onToggle: () => setDialogState(() => obscurePass = !obscurePass)),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: _buildDialogButton("Cancel", Colors.white, Colors.grey, () => Navigator.pop(dialogContext))),
                    const SizedBox(width: 15),
                    Expanded(child: _buildDialogButton("Delete", Colors.red, Colors.white, () async {
                      // Capture Navigator and Messenger before async gaps
                      final navigator = Navigator.of(context, rootNavigator: true);
                      final messenger = ScaffoldMessenger.of(context);

                      Navigator.pop(dialogContext); // Close input dialog
                      _showLoadingDialog();

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final cred = EmailAuthProvider.credential(email: user.email!, password: passwordCtrl.text);
                          await user.reauthenticateWithCredential(cred);
                          await AuthService().deleteAccount();
                        }
                        
                        messenger.showSnackBar(const SnackBar(content: Text("Account Deleted Successfully")));
                        
                        // Push to login and clear all previous screens
                        // Note: Ensure '/login' exists in your routes
                        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                      } catch (e) {
                        if (mounted) {
                          navigator.pop(); // Remove loading dialog using captured navigator
                          _showMessageDialog(title: "Error", message: "Failed to delete account. Check password.", titleColor: Colors.red);
                        }
                      }
                    })),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Builders ---

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      pageBuilder: (_, __, ___) => MenuDrawer(isAdmin: _isAdmin, currentScreen: 'Setting'),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
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
        margin: const EdgeInsets.only(right: 25, top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: borderWidth),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(3, 3))],
        ),
        child: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface, size: 30),
      ),
    );
  }

  Widget _buildDialogField({required String hint, required IconData icon, required TextEditingController controller, required bool isObscure, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle),
        hintText: hint,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.grey, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.black, width: 2)),
      ),
    );
  }

  Widget _buildDialogButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black, width: 3)),
        child: Center(child: Text(text, style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w900, fontSize: 18))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, toolbarHeight: 80, automaticallyImplyLeading: false, actions: [_buildMenuButton()]),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Text('Settings', style: GoogleFonts.montserrat(fontSize: 48, fontWeight: FontWeight.w900, color: textColor)),
          const SizedBox(height: 30),
          _SettingSection(title: 'Preferences', children: [
            Consumer<ThemeProvider>(builder: (context, theme, child) => _ToggleTile(label: 'Dark Mode', value: theme.isDarkMode, activeColor: themeYellow, onChanged: (v) => theme.setTheme(v))),
            const Divider(height: 1),
            _ActionTile(label: 'Language', icon: Icons.language, trailingText: 'English', onTap: () {}),
          ]),
          const SizedBox(height: 25),
          _SettingSection(title: 'Support', children: [
            _ActionTile(label: 'Report a Bug', icon: Icons.bug_report, onTap: () => _sendEmail(subject: '[BUG]', body: '')),
            const Divider(height: 1),
            _ActionTile(label: 'Feature Request', icon: Icons.lightbulb, onTap: () => _sendEmail(subject: '[FEATURE]', body: '')),
          ]),
          const SizedBox(height: 25),
          _SettingSection(title: 'Account', children: [
            _ActionTile(label: 'Change Password', icon: Icons.lock, onTap: _showChangePasswordDialog),
            const Divider(height: 1),
            _ActionTile(label: 'Delete Account', icon: Icons.delete, color: Colors.red, onTap: _showDeleteAccountDialog),
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
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 12, color: textColor.withValues(alpha: 0.5))),
      const SizedBox(height: 10),
      Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(width: 3, color: textColor), borderRadius: BorderRadius.circular(12)), child: Column(children: children)),
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
    // Fixed deprecated activeColor to activeThumbColor
    return SwitchListTile(title: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)), value: value, activeThumbColor: activeColor, onChanged: onChanged);
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
        if (trailingText != null) Text(trailingText!, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Icon(Icons.arrow_forward_ios, size: 14),
      ]),
      onTap: onTap,
    );
  }
}