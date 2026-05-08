import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_management_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const double borderWidth = 3.0;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await UserManagementService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              (user['name'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (user['email'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- 1. CHANGE ROLE (WITH CONFIRMATION) ---
  Future<void> _changeRole(String uid, String name, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : darkBorder;
    final cardColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: textColor, width: 3)),
        title: Text('Change Role?',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor)),
        content: Text('Change $name from ${currentRole.toUpperCase()} to ${newRole.toUpperCase()}?',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CONFIRM', style: GoogleFonts.montserrat(color: const Color(0xFF00CBA9), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserManagementService.updateUserRole(uid, newRole);
      _loadUsers();
    }
  }

  // --- 2. EDIT USER DIALOG (Matches your image) ---
  Future<void> _editUser(Map<String, dynamic> user) async {
    final nameCtrl = TextEditingController(text: user['name'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    String tempRole = user['role'] ?? 'student';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : darkBorder;
          final cardColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;

          return Dialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: textColor, width: 3)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit User',
                      style: GoogleFonts.montserrat(
                          fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 24),
                  _buildEditField('Full Name', Icons.person_outline, nameCtrl, textColor),
                  const SizedBox(height: 16),
                  _buildEditField('Email', Icons.mail_outline, emailCtrl, textColor),
                  const SizedBox(height: 20),
                  Text('ROLE',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _roleOption(
                        label: 'Student',
                        icon: Icons.school_outlined,
                        isSelected: tempRole == 'student',
                        activeColor: const Color(0xFF00CBA9),
                        onTap: () => setDialogState(() => tempRole = 'student'),
                      ),
                      const SizedBox(width: 12),
                      _roleOption(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        isSelected: tempRole == 'admin',
                        activeColor: const Color(0xFFFFBC1F),
                        onTap: () => setDialogState(() => tempRole = 'admin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogBtn(
                          label: 'Cancel',
                          color: Colors.white,
                          textColor: Colors.grey,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dialogBtn(
                          label: 'Save',
                          color: const Color(0xFF00CBA9),
                          textColor: Colors.white,
                          hasShadow: true,
                          onTap: () async {
                            await UserManagementService.updateUser(
                              uid: user['uid'],
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              role: tempRole,
                            );
                            if (context.mounted) Navigator.pop(context);
                            _loadUsers();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. DELETE USER ---
  Future<void> _deleteUser(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: darkBorder, width: 3)),
        title: Text('Delete User', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.red)),
        content: Text('Delete $name?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w700))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w900))),
        ],
      ),
    );
    if (confirm == true) {
      await UserManagementService.deleteUserData(uid);
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;
    final cardColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
    final textColor = isDark ? Colors.white : darkBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: textColor, width: 2.5),
                        boxShadow: [BoxShadow(color: textColor, offset: const Offset(3, 3))],
                      ),
                      child: Icon(Icons.arrow_back, color: textColor, size: 28),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Manage\nUsers', style: GoogleFonts.montserrat(fontSize: 48, fontWeight: FontWeight.w900, color: textColor, height: 1.0, letterSpacing: -1)),
                ],
              ),
            ),
            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: textColor, width: borderWidth),
                  boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filterUsers,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search, color: textColor, size: 28),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            // LIST
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final user = _filteredUsers[index];
                        final name = user['name'] ?? 'Unknown';
                        final email = user['email'] ?? '';
                        final role = user['role'] ?? 'student';
                        final isAdmin = role == 'admin';

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: textColor, width: borderWidth),
                            boxShadow: [BoxShadow(color: textColor, offset: const Offset(5, 5))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                _profileCircle(name, isAdmin, user['profileImage'], textColor),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 15, color: textColor)),
                                      Text(email, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _changeRole(user['uid'], name, role),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAdmin ? const Color(0xFFFFBC1F).withValues(alpha: 0.2) : const Color(0xFF00CBA9).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9), width: 1.5),
                                          ),
                                          child: Text(role.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: isAdmin ? const Color(0xFFE5A500) : const Color(0xFF00A388))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () => _editUser(user), icon: const Icon(Icons.edit_outlined, color: Color(0xFF00CBA9))),
                                IconButton(onPressed: () => _deleteUser(user['uid'], name), icon: const Icon(Icons.delete_outline_rounded, color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen()));
          _loadUsers();
        },
        backgroundColor: const Color(0xFF00CBA9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: textColor, width: 2.5)),
        label: Text('ADD USER', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white)),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _profileCircle(String name, bool isAdmin, String? img, Color textColor) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle, color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9), border: Border.all(color: textColor, width: 2.5)),
      child: ClipOval(
        child: (img != null && img.isNotEmpty) 
          ? Image.network(img, fit: BoxFit.cover, errorBuilder: (c, e, s) => _initials(name)) 
          : _initials(name),
      ),
    );
  }

  Widget _initials(String name) => Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)));

  Widget _buildEditField(String label, IconData icon, TextEditingController ctrl, Color textColor) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: textColor, width: 2)),
      ),
    );
  }

  Widget _roleOption({required String label, required IconData icon, required bool isSelected, required Color activeColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300, width: isSelected ? 3 : 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: isSelected ? activeColor : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogBtn({required String label, required Color color, required Color textColor, required VoidCallback onTap, bool hasShadow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBorder, width: 2.5),
          boxShadow: hasShadow ? [const BoxShadow(color: darkBorder, offset: Offset(0, 4))] : null,
        ),
        child: Center(child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor, fontSize: 16))),
      ),
    );
  }
}

// --- ADD USER SCREEN ---

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});
  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: bgColor, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300], border: Border.all(color: textColor, width: 3), boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))]),
                child: Icon(Icons.camera_alt_outlined, size: 40, color: textColor),
              ),
            ),
            const SizedBox(height: 30),
            Text('Create\nAccount', style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, color: textColor, height: 1.0)),
            const SizedBox(height: 30),
            _buildField('Full Name', _nameCtrl, textColor, isDark),
            const SizedBox(height: 16),
            _buildField('Email Address', _emailCtrl, textColor, isDark),
            const SizedBox(height: 16),
            _buildField('Password', _passwordCtrl, textColor, isDark, obscure: true),
            const SizedBox(height: 24),
            Row(children: [_roleBtn('student', Icons.school), const SizedBox(width: 12), _roleBtn('admin', Icons.admin_panel_settings)]),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                await UserManagementService.createUser(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), password: _passwordCtrl.text.trim(), role: _selectedRole);
                if (context.mounted) Navigator.pop(context);
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(color: const Color(0xFF00CBA9), borderRadius: BorderRadius.circular(16), border: Border.all(color: textColor, width: 3), boxShadow: [BoxShadow(color: textColor, offset: const Offset(0, 4))]),
                child: Center(child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('CREATE USER', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBtn(String role, IconData icon) {
    bool isSel = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSel ? (role == 'admin' ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9)) : Colors.transparent, border: Border.all(color: const Color(0xFF1A1C1E), width: 2.5), borderRadius: BorderRadius.circular(12), boxShadow: isSel ? [const BoxShadow(color: Color(0xFF1A1C1E), offset: Offset(2, 2))] : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSel ? Colors.white : Colors.grey, size: 20), const SizedBox(width: 8), Text(role.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: isSel ? Colors.white : Colors.grey, fontSize: 12))]),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, Color textColor, bool isDark, {bool obscure = false}) {
    return TextField(
      controller: ctrl, obscureText: obscure,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label, filled: true, fillColor: isDark ? const Color(0xFF2A2D2E) : Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: textColor, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00CBA9), width: 3)),
      ),
    );
  }
}