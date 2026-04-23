import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import '../widgets/custom_bottom_nav.dart'; // Ensure consistency

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Styling Constants (Identical to HomeScreen)
  static const double borderWidth = 3.0;
  final Color themeYellow = const Color(0xFFFFB82E);

  // State Variables
  bool _notifications = true;
  String _language = 'English';
  String _userRole = 'student';

  bool get _isAdmin => _userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  /// Fetch user role for MenuDrawer (Identical to HomeScreen logic)
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

  /// Side Menu Animation (Identical to HomeScreen)
  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (_, __, ___) => MenuDrawer(isAdmin: _isAdmin, currentScreen: 'Setting'),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
            child: child,
          );
        },
      ),
    );
  }

  /// Reusable Styled Menu Button (Identical to HomeScreen)
  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _openDrawer(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: borderWidth),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(3, 3))
          ],
        ),
        child: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface, size: 30),
      ),
    );
  }

  // --- ACCOUNT LOGIC (Functionalities Kept Intact) ---

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Password', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) { _showSnack('Passwords do not match'); return; }
              Navigator.pop(context);
              try {
                final user = FirebaseAuth.instance.currentUser;
                final cred = EmailAuthProvider.credential(email: user!.email!, password: currentCtrl.text);
                await user.reauthenticateWithCredential(cred);
                await AuthService().changePassword(newCtrl.text);
                _showSnack('Password changed successfully!');
              } catch (e) { _showSnack('Error: ${e.toString()}'); }
            },
            child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
        title: Text('Delete Account', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is permanent. Enter password to confirm.'),
            const SizedBox(height: 15),
            _inputField('Password', passwordCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user = FirebaseAuth.instance.currentUser;
                final cred = EmailAuthProvider.credential(email: user!.email!, password: passwordCtrl.text);
                await user.reauthenticateWithCredential(cred);
                await AuthService().deleteAccount();
//                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              } catch (e) { _showSnack('Error: ${e.toString()}'); }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(controller: controller, obscureText: true, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Removed AppBar to match HomeScreen's manual header structure
      body: SafeArea(
        child: Column(
          children: [
            /// 1. HEADER (Matches HomeScreen Spacing and Layout)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  _buildMenuButton(),
                ],
              ),
            ),

            /// 2. SETTINGS CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 100),
                children: [
                  const SizedBox(height: 20),
                  _SettingSection(title: 'Preferences', children: [
                    _ToggleTile(
                      label: 'Notifications',
                      value: _notifications,
                      activeColor: themeYellow,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    const Divider(height: 1, thickness: 1),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _ToggleTile(
                          label: 'Dark Mode',
                          value: themeProvider.isDarkMode,
                          activeColor: themeYellow,
                          onChanged: (v) => themeProvider.setTheme(v),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 25),

                  _SettingSection(title: 'Language', children: [
                    RadioGroup<String>(
                      groupValue: _language,
                      onChanged: (v) { if (v != null) setState(() => _language = v); },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('English', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                            value: 'English',
                            activeColor: themeYellow,
                          ),
                          const Divider(height: 1, thickness: 1),
                          RadioListTile<String>(
                            title: Text('Filipino', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                            value: 'Filipino',
                            activeColor: themeYellow,
                          ),
                        ],
                      ),
                    )
                  ]),

                  const SizedBox(height: 25),

                  _SettingSection(title: 'Account', children: [
                    _ActionTile(label: 'Change Password', icon: Icons.lock_outline, onTap: _showChangePasswordDialog),
                    const Divider(height: 1, thickness: 1),
                    _ActionTile(label: 'Delete Account', icon: Icons.delete_outline, color: Colors.red, onTap: _showDeleteAccountDialog),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-widgets with updated Neo-brutalist border width to match HomeScreen (3.0)
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
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 3.0, color: Theme.of(context).colorScheme.onSurface),
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

  const _ToggleTile({required this.label, required this.value, required this.activeColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
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
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({required this.label, required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: tileColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: tileColor),
      onTap: onTap,
    );
  }
}