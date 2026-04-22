import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../widgets/admin_widgets.dart';

class ManageModulesScreen extends StatefulWidget {
  const ManageModulesScreen({super.key});

  @override
  State<ManageModulesScreen> createState() => _ManageModulesScreenState();
}

class _ManageModulesScreenState extends State<ManageModulesScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  String? _selectedCourseId;
  String _searchQuery = '';

  Future<void> _deleteModule(String courseId, String moduleId, String moduleName) async {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Module',
        content: 'Are you sure you want to delete "$moduleName"?',
        onConfirm: () async {
          try {
            await FirestoreService().deleteModule(courseId, moduleId);
            if (!mounted) return;
            messenger.showSnackBar(SnackBar(content: Text('Module deleted'), backgroundColor: Colors.green));
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  /// Exact same back button from your sample
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: darkBorder, width: 2.5),
          boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(4, 4))],
        ),
        child: const Icon(Icons.arrow_back, color: darkBorder, size: 26),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        letterSpacing: 1.2,
        color: darkBorder,
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
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 12),
            child: Row(children: [_buildBackButton()]),
          ),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: FirestoreService().getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: darkBorder));
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) return const Center(child: Text("No Courses found"));

          // Initialize selected course
          _selectedCourseId ??= courses.first.id;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BOLD HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Manage\nModules',
                  style: GoogleFonts.montserrat(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.5,
                    color: darkBorder,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // COURSE SELECTOR DROPDOWN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SELECT COURSE'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkBorder, width: 2.5),
                        boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(4, 4))],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourseId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: darkBorder),
                          style: GoogleFonts.montserrat(color: darkBorder, fontWeight: FontWeight.w700, fontSize: 16),
                          items: courses.map((course) {
                            return DropdownMenuItem(value: course.id, child: Text(course.title.toUpperCase()));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCourseId = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: darkBorder, width: 2.5),
                    boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Search modules...',
                      hintStyle: GoogleFonts.montserrat(color: Colors.black26),
                      prefixIcon: const Icon(Icons.search, color: darkBorder),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // MODULES LIST
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirestoreService().getModules(_selectedCourseId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: darkBorder));
                    }

                    final filteredModules = snapshot.data?.where((m) =>
                      (m['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList() ?? [];

                    if (filteredModules.isEmpty) {
                      return Center(child: Text('No modules found.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredModules.length,
                      itemBuilder: (context, index) {
                        final module = filteredModules[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: darkBorder, width: 2.5),
                            boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(4, 4))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            title: Text(
                              module['title']?.toString().toUpperCase() ?? 'UNTITLED',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            subtitle: Text(
                              module['description'] ?? 'No description',
                              maxLines: 1,
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                              onPressed: () => _deleteModule(_selectedCourseId!, module['id'], module['title']),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}