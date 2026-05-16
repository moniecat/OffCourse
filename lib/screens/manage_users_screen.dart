import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_management_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // NEOBRUTALIST STYLE CONSTANTS
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const double borderWidth = 3.0;
  static const Color primaryTeal = Color(0xFF00CBA9);
  static const Color adminGold = Color(0xFFFFBC1F);

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  // Track the current filter role
  String _selectedRoleFilter = 'all'; 

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
          _applyFilters(); // Apply current search and role filters
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Unified Filtering: Handles both Search text and Selected Role
  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final nameMatches = (user['name'] ?? '').toLowerCase().contains(query);
        final emailMatches = (user['email'] ?? '').toLowerCase().contains(query);
        
        // Check if user role matches the filter selection
        final roleMatches = _selectedRoleFilter == 'all' || 
                           (user['role'] ?? 'student').toLowerCase() == _selectedRoleFilter;

        return (nameMatches || emailMatches) && roleMatches;
      }).toList();
    });
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
            // HEADER SECTION
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

            // SEARCH BAR
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
                  onChanged: (v) => _applyFilters(),
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

            // ACTION ROW (ADD BUTTON + FILTER ICON)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
              child: Row(
                children: [
                  // ADD NEW USER BUTTON
                  Expanded(
                    child: GestureDetector(
                      onTap: _showAddUserFloater,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: primaryTeal,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: textColor, width: borderWidth),
                          boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Text('ADD NEW USER', 
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 0.5)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // FILTER ICON BUTTON
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        _selectedRoleFilter = value;
                        _applyFilters();
                      });
                    },
                    offset: const Offset(0, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: textColor, width: 2),
                    ),
                    itemBuilder: (context) => [
                      _buildPopupItem('all', Icons.people_outline, 'All Users'),
                      _buildPopupItem('admin', Icons.admin_panel_settings_outlined, 'Admins'),
                      _buildPopupItem('student', Icons.school_outlined, 'Students'),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: textColor, width: borderWidth),
                        boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
                      ),
                      child: Icon(
                        _selectedRoleFilter == 'all' ? Icons.filter_list_rounded : Icons.filter_list_alt,
                        color: _selectedRoleFilter == 'all' ? textColor : primaryTeal,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // USER LIST SECTION
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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
                                    color: isAdmin ? adminGold : primaryTeal,
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
                                            color: isAdmin ? adminGold.withValues(alpha: 0.2) : primaryTeal.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: isAdmin ? adminGold : primaryTeal, width: 1.5),
                                          ),
                                          child: Text(role.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: isAdmin ? const Color(0xFFE5A500) : const Color(0xFF00A388))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () => _editUser(user), icon: const Icon(Icons.edit_outlined, color: primaryTeal, size: 24)),
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
    );
  }

  // --- POPUP MENU ITEM HELPER ---
  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label) {
    bool isSelected = _selectedRoleFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? primaryTeal : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, 
            style: GoogleFonts.montserrat(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? darkBorder : Colors.grey[700],
            )
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS & MODALS ---

  Widget _initials(String name) {
    return Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white)));
  }

  void _showAddUserFloater() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'student';
    bool nameErr = false, emailErr = false, passErr = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : darkBorder;
          final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: textColor, width: 4),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('Create User', style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 24),
                  _buildFloaterField('Full Name', nameCtrl, false, nameErr, setModalState),
                  const SizedBox(height: 16),
                  _buildFloaterField('Email Address', emailCtrl, false, emailErr, setModalState),
                  const SizedBox(height: 16),
                  _buildFloaterField('Password', passCtrl, true, passErr, setModalState),
                  const SizedBox(height: 24),
                  Text('ROLE', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _floaterRoleBtn('student', Icons.school_outlined, selectedRole, primaryTeal, (r) => setModalState(() => selectedRole = r)),
                      const SizedBox(width: 12),
                      _floaterRoleBtn('admin', Icons.admin_panel_settings_outlined, selectedRole, adminGold, (r) => setModalState(() => selectedRole = r)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: isSaving ? null : () async {
                      setModalState(() {
                        nameErr = nameCtrl.text.trim().isEmpty;
                        emailErr = emailCtrl.text.trim().isEmpty;
                        passErr = passCtrl.text.trim().isEmpty;
                      });

                      if (!nameErr && !emailErr && !passErr) {
                        setModalState(() => isSaving = true);
                        try {
                          await UserManagementService.createUser(
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                            role: selectedRole,
                          );
                          if (context.mounted) Navigator.pop(context);
                          _loadUsers();
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                content: Text(e.toString().replaceAll(RegExp(r'\[.*?\]'), ''), 
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: primaryTeal,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkBorder, width: 3),
                        boxShadow: [const BoxShadow(color: darkBorder, offset: Offset(0, 4))],
                      ),
                      child: Center(
                        child: isSaving 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text('SAVE USER', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: textColor, width: 3)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit User', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 24),
                  _buildEditField('Full Name', Icons.person_outline, nameCtrl, textColor),
                  const SizedBox(height: 16),
                  _buildEditField('Email', Icons.mail_outline, emailCtrl, textColor),
                  const SizedBox(height: 20),
                  Text('ROLE', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _roleOption(label: 'Student', icon: Icons.school_outlined, isSelected: tempRole == 'student', activeColor: primaryTeal, textColor: textColor, onTap: () => setDialogState(() => tempRole = 'student')),
                      const SizedBox(width: 12),
                      _roleOption(label: 'Admin', icon: Icons.admin_panel_settings_outlined, isSelected: tempRole == 'admin', activeColor: adminGold, textColor: textColor, onTap: () => setDialogState(() => tempRole = 'admin')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: _dialogBtn(label: 'Cancel', color: Colors.white, textColor: Colors.grey, onTap: () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _dialogBtn(label: 'Save', color: primaryTeal, textColor: Colors.white, hasShadow: true, onTap: () async {
                        await UserManagementService.updateUser(uid: user['uid'], name: nameCtrl.text.trim(), email: emailCtrl.text.trim(), role: tempRole);
                        if (context.mounted) Navigator.pop(context);
                        _loadUsers();
                      })),
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
    final roleColor = newRole == 'admin' ? adminGold : primaryTeal;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: darkBorder, width: 3)),
        title: Text('Switch Role', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: darkBorder)),
        content: Text('Change this user to ${newRole.toUpperCase()}?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL', style: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w700))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('CONFIRM', style: GoogleFonts.montserrat(color: roleColor, fontWeight: FontWeight.w900))),
        ],
      ),
    );
    if (confirm == true) {
      await UserManagementService.updateUserRole(uid, newRole);
      _loadUsers();
    }
  }

  Widget _buildFloaterField(String label, TextEditingController ctrl, bool obscure, bool hasErr, Function setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: hasErr ? Colors.red : darkBorder, width: 3)),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            onChanged: (v) { if(hasErr) setModalState(() => hasErr = false); },
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: darkBorder),
            decoration: InputDecoration(hintText: label, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
          ),
        ),
        if (hasErr) Padding(padding: const EdgeInsets.only(left: 8, top: 4), child: Text("Required field", style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12))),
      ],
    );
  }

  Widget _floaterRoleBtn(String role, IconData icon, String selected, Color activeColor, Function(String) onSelect) {
    bool isSel = selected == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: isSel ? activeColor : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSel ? activeColor : Colors.grey.shade300, width: 3)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: isSel ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(role.toUpperCase(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: isSel ? Colors.white : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, IconData icon, TextEditingController ctrl, Color textColor) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: Colors.grey),
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
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: isSelected ? activeColor : Colors.grey)),
          ]),
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
          color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: darkBorder, width: 2.5),
          boxShadow: hasShadow ? [const BoxShadow(color: darkBorder, offset: Offset(0, 4))] : null,
        ),
        child: Center(child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor, fontSize: 16))),
      ),
    );
  }
}