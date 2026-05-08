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

  // --- EDIT USER DIALOG ---
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
              side: BorderSide(color: textColor, width: 3),
            ),
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
                        textColor: textColor,
                        onTap: () => setDialogState(() => tempRole = 'student'),
                      ),
                      const SizedBox(width: 12),
                      _roleOption(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        isSelected: tempRole == 'admin',
                        activeColor: const Color(0xFFFFBC1F),
                        textColor: textColor,
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

  Future<void> _changeRole(String uid, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';
    await UserManagementService.updateUserRole(uid, newRole);
    _loadUsers();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final user = _filteredUsers[index];
                        final String name = user['name'] ?? 'Unknown';
                        final String email = user['email'] ?? '';
                        final String role = user['role'] ?? 'student';
                        final String? profileImg = user['profileImage'];
                        final bool isAdmin = role == 'admin';

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
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAdmin ? const Color(0xFFFFBC1F) : const Color(0xFF00CBA9),
                                    border: Border.all(color: textColor, width: 2.5),
                                  ),
                                  child: ClipOval(
                                    child: (profileImg != null && profileImg.isNotEmpty)
                                        ? Image.network(profileImg, fit: BoxFit.cover, errorBuilder: (c, e, s) => _initials(name))
                                        : _initials(name),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 15, color: textColor)),
                                      Text(email, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _changeRole(user['uid'], role),
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
                                IconButton(onPressed: () => _editUser(user), icon: const Icon(Icons.edit_outlined, color: Color(0xFF00CBA9), size: 24)),
                                IconButton(onPressed: () => _deleteUser(user['uid'], name), icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24)),
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

  Widget _initials(String name) {
    return Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)));
  }

  Widget _buildEditField(String label, IconData icon, TextEditingController ctrl, Color textColor) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: textColor, width: 2)),
      ),
    );
  }

  Widget _roleOption({required String label, required IconData icon, required bool isSelected, required Color activeColor, required Color textColor, required VoidCallback onTap}) {
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
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBorder, width: 2.5),
          boxShadow: hasShadow ? [const BoxShadow(color: darkBorder, offset: Offset(0, 4))] : null,
        ),
        child: Center(child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor, fontSize: 16))),
      ),
    );
  }
}

// --- ADD USER SCREEN WIDGET ---

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  // 1. Add error tracking variables
  bool _nameError = false;
  bool _emailError = false;
  bool _passError = false;

  String _selectedRole = 'admin'; 
  bool _isLoading = false;

  final Color darkBorder = const Color(0xFF1A1C1E);
  final Color tealPrimary = const Color(0xFF00CBA9);
  final Color yellowPrimary = const Color(0xFFFFBC1F);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : darkBorder;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: darkBorder, width: 3),
                    boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(4, 4))],
                  ),
                  child: Icon(Icons.arrow_back, color: darkBorder, size: 28),
                ),
              ),
              const SizedBox(height: 12),
              Text('Create\nAccount', 
                style: GoogleFonts.montserrat(fontSize: 54, fontWeight: FontWeight.w900, color: textColor, height: 0.85, letterSpacing: -3)),
              
              const SizedBox(height: 40),

              // 2. Pass the error state to the fields
              _buildField('Full Name', _nameCtrl, false, _nameError),
              const SizedBox(height: 16),
              _buildField('Email Address', _emailCtrl, false, _emailError),
              const SizedBox(height: 16),
              _buildField('Password', _passwordCtrl, true, _passError),

              const SizedBox(height: 32),
              Text('SELECT ROLE', 
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _roleBtn('student', Icons.school_outlined),
                  const SizedBox(width: 16),
                  _roleBtn('admin', Icons.admin_panel_settings_outlined),
                ],
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: _isLoading ? null : _handleCreate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: tealPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: darkBorder, width: 3),
                    boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text('CREATE USER', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20, letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Updated Helper to show Red Border if hasError is true
  Widget _buildField(String label, TextEditingController ctrl, bool obscure, bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            // Border turns RED if hasError is true
            border: Border.all(color: hasError ? Colors.red : darkBorder, width: 3),
            boxShadow: [
              BoxShadow(
                color: hasError ? Colors.red.withOpacity(0.2) : Colors.grey.shade200, 
                offset: const Offset(4, 4)
              )
            ],
          ),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            onChanged: (val) {
              // Reset error when user starts typing
              if (hasError && val.isNotEmpty) {
                setState(() {
                   if (ctrl == _nameCtrl) _nameError = false;
                   if (ctrl == _emailCtrl) _emailError = false;
                   if (ctrl == _passwordCtrl) _passError = false;
                });
              }
            },
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: darkBorder),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.montserrat(color: hasError ? Colors.red.withOpacity(0.5) : Colors.grey.shade400, fontWeight: FontWeight.w700),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        if (hasError) 
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text("Required field", style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
      ],
    );
  }

  // 4. Update the handleCreate logic
  void _handleCreate() async {
    // Check for "No Sulod" (Empty content)
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty;
      _emailError = _emailCtrl.text.trim().isEmpty;
      _passError = _passwordCtrl.text.trim().isEmpty;
    });

    // If any are empty, stop here
    if (_nameError || _emailError || _passError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await UserManagementService.createUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: _selectedRole,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _roleBtn(String role, IconData icon) {
    bool isSel = _selectedRole == role;
    Color btnColor = role == 'admin' ? yellowPrimary : tealPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isSel ? btnColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isSel ? btnColor : Colors.grey.shade400, width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSel ? Colors.white : Colors.grey, size: 24),
              const SizedBox(width: 10),
              Text(role.toUpperCase(), 
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: isSel ? Colors.white : Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}