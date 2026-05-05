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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await UserManagementService.getAllUsers();
      if (mounted) setState(() { _users = users; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _changeRole(String uid, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Role', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
        content: Text(
          'Change this user to ${newRole == 'admin' ? 'Admin' : 'Student'}?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: const Color(0xFF249780))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserManagementService.updateUserRole(uid, newRole);
      _loadUsers();
    }
  }

  Future<void> _deleteUser(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete User', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.red)),
        content: Text(
          'Delete $name? This only removes their Firestore data.',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserManagementService.deleteUserData(uid);
      _loadUsers();
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final uid = user['uid'] as String;
    final nameCtrl = TextEditingController(text: user['name'] as String? ?? '');
    final emailCtrl = TextEditingController(text: user['email'] as String? ?? '');
    String selectedRole = user['role'] as String? ?? 'student';

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
          final textColor = isDark ? Colors.white : darkBorder;

          return Dialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: textColor, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit User', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 20),
                  _buildSheetField('Full Name', nameCtrl, textColor, isDark, icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildSheetField('Email', emailCtrl, textColor, isDark, icon: Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  Text('ROLE', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: textColor.withValues(alpha: 0.5), letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['student', 'admin'].map((role) {
                      final isSelected = selectedRole == role;
                      final color = role == 'admin' ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedRole = role),
                          child: Container(
                            margin: EdgeInsets.only(right: role == 'student' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withValues(alpha: 0.15) : bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? color : textColor.withValues(alpha: 0.3), width: isSelected ? 2.5 : 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(role == 'admin' ? Icons.admin_panel_settings_rounded : Icons.school_rounded, color: isSelected ? color : textColor.withValues(alpha: 0.5), size: 20),
                                const SizedBox(width: 6),
                                Text(role == 'admin' ? 'Admin' : 'Student', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? color : textColor.withValues(alpha: 0.5))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Center(child: Text('Cancel', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w800, color: textColor.withValues(alpha: 0.6)))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            await UserManagementService.updateUser(
                              uid: uid,
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              role: selectedRole,
                            );
                            _loadUsers();
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00CBA9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: textColor, width: 2),
                              boxShadow: [BoxShadow(color: textColor, offset: const Offset(0, 3))],
                            ),
                            child: Center(child: Text('Save', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white))),
                          ),
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

  Widget _buildSheetField(String label, TextEditingController ctrl, Color textColor, bool isDark, {IconData? icon, TextInputType? type, bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: type,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: textColor.withValues(alpha: 0.6), size: 20) : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1C1E) : Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: textColor.withValues(alpha: 0.3), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00CBA9), width: 2.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : darkBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          'Manage Users',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
          _loadUsers();
        },
        backgroundColor: const Color(0xFF00CBA9),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add User', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _users.isEmpty
                  ? Center(child: Text('No users found', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final user = _users[index];
                        final uid = user['uid'] as String;
                        final name = user['name'] as String? ?? 'Unknown';
                        final email = user['email'] as String? ?? '';
                        final role = user['role'] as String? ?? 'student';
                        final isAdmin = role == 'admin';

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2D2E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: textColor, width: borderWidth),
                            boxShadow: [BoxShadow(color: textColor, offset: const Offset(3, 3))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: textColor, width: 2),
                                color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9),
                              ),
                              child: ClipOval(
                                child: (user['profileImage'] != null && (user['profileImage'] as String).isNotEmpty)
                                    ? Image.network(
                                        user['profileImage'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: textColor)),
                            subtitle: Text(email, style: GoogleFonts.montserrat(fontSize: 12, color: textColor.withValues(alpha: 0.6))),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Role badge
                                GestureDetector(
                                  onTap: () => _changeRole(uid, role),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? const Color(0xFFFFBC1F).withValues(alpha: 0.15)
                                          : const Color(0xFF00CBA9).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      isAdmin ? 'Admin' : 'Student',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Edit icon
                                GestureDetector(
                                  onTap: () => _editUser(user),
                                  child: const Icon(Icons.edit_rounded, color: Color(0xFF249780), size: 22),
                                ),
                                const SizedBox(width: 8),
                                // Delete icon
                                GestureDetector(
                                  onTap: () => _deleteUser(uid, name),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      await UserManagementService.createUser(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : darkBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          'Add User',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Account', style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, height: 1.0)),
            const SizedBox(height: 6),
            Text('New user will be able to log in immediately.', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: textColor.withValues(alpha: 0.6))),
            const SizedBox(height: 32),

            _buildField('Full Name', _nameCtrl, textColor, isDark, icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildField('Email Address', _emailCtrl, textColor, isDark, icon: Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField('Password', _passwordCtrl, textColor, isDark, icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 24),

            Text('ROLE', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: textColor.withValues(alpha: 0.5), letterSpacing: 1.5)),
            const SizedBox(height: 10),
            
            Row(
              children: ['student', 'admin'].map((role) {
                final isSelected = _selectedRole == role;
                final color = role == 'admin' ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9);
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
                final textColor = isDark ? Colors.white : darkBorder;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: Container(
                      margin: EdgeInsets.only(right: role == 'student' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color : bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : textColor.withValues(alpha: 0.3),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.4), offset: const Offset(0, 3), blurRadius: 0)]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            role == 'admin' ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                            color: isSelected ? Colors.white : textColor.withValues(alpha: 0.5),
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            role == 'admin' ? 'Admin' : 'Student',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFE0E0), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade300)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: GoogleFonts.montserrat(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading ? null : _createUser,
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF00CBA9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: textColor, width: 2.5),
                  boxShadow: [BoxShadow(color: textColor, offset: const Offset(0, 5))],
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Create Account', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, Color textColor, bool isDark, {IconData? icon, TextInputType? type, bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: type,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
        prefixIcon: icon != null ? Icon(icon, color: textColor.withValues(alpha: 0.6)) : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2D2E) : Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: textColor.withValues(alpha: 0.3), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF00CBA9), width: 2.5)),
      ),
    );
  }
}