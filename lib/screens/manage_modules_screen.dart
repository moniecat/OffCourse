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
    // Capture the messenger reference before the async operation
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Module',
        content: 'Are you sure you want to delete "$moduleName"?\nThis will also delete all questions in this module.',
        onConfirm: () async {
          try {
            await FirestoreService().deleteModule(courseId, moduleId);
            
            if (!mounted) return;

            messenger.showSnackBar(
              SnackBar(
                content: Text('Module "$moduleName" deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } catch (e) {
            if (!mounted) return;

            messenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to delete module'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: Text(
          'Manage Modules',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkBorder,
          ),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: FirestoreService().getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AdminEmptyState(
              title: 'No Courses Found',
              subtitle: 'Create a course first to add modules',
              icon: Icons.library_add_rounded,
            );
          }

          final courses = snapshot.data!;
          final selectedCourse = _selectedCourseId != null
              ? courses.firstWhere((c) => c.id == _selectedCourseId, orElse: () => courses.first)
              : courses.first;

          _selectedCourseId ??= selectedCourse.id;

          return Column(
            children: [
              AdminDropdown<String>(
                label: 'SELECT COURSE',
                hint: 'Choose a course',
                value: _selectedCourseId,
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                    _searchQuery = '';
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirestoreService().getModules(_selectedCourseId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return AdminEmptyState(
                        title: 'No Modules Found',
                        subtitle: 'Add your first module to this course',
                        icon: Icons.layers_outlined,
                      );
                    }

                    final allModules = snapshot.data!;
                    final filteredModules = allModules
                        .where((module) =>
                            (module['title'] ?? '')
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            (module['description'] ?? '')
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();

                    return Column(
                      children: [
                        AdminSearchBar(
                          hint: 'Search modules...',
                          value: _searchQuery,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        Expanded(
                          child: filteredModules.isEmpty
                              ? AdminEmptyState(
                                  title: 'No Results',
                                  subtitle: 'Try searching with different keywords',
                                  icon: Icons.search_rounded,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredModules.length,
                                  itemBuilder: (context, index) {
                                    final module = filteredModules[index];
                                    return AdminListItem(
                                      title: module['title'] ?? 'Untitled',
                                      subtitle: module['description'] ?? 'No description',
                                      badge: '${index + 1}/${filteredModules.length}',
                                      accentColor: const Color(0xFFFFBC1F),
                                      onDelete: () => _deleteModule(
                                        _selectedCourseId!,
                                        module['id'],
                                        module['title'] ?? 'Module',
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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