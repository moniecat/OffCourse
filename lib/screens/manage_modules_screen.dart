import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';

class ManageModulesScreen extends StatefulWidget {
  const ManageModulesScreen({super.key});

  @override
  State<ManageModulesScreen> createState() => _ManageModulesScreenState();
}

class _ManageModulesScreenState extends State<ManageModulesScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  String? _selectedCourseId;

  Future<void> _deleteModule(String courseId, String moduleId, String moduleName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text('Are you sure you want to delete "$moduleName"?\nThis will also delete all questions in this module.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirestoreService().deleteModule(courseId, moduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Module "$moduleName" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete module'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            return const Center(child: Text('No courses found'));
          }

          final courses = snapshot.data!;
          final selectedCourse = _selectedCourseId != null
              ? courses.firstWhere((c) => c.id == _selectedCourseId, orElse: () => courses.first)
              : courses.first;

          _selectedCourseId ??= selectedCourse.id;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<String>(
                  value: _selectedCourseId,
                  isExpanded: true,
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course.id,
                      child: Text(course.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirestoreService().getModules(_selectedCourseId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No modules found'));
                    }

                    final modules = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module['title'] ?? 'Untitled',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (module['description'] != null)
                                          Text(
                                            module['description'],
                                            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteModule(
                                      _selectedCourseId!,
                                      module['id'],
                                      module['title'] ?? 'Module',
                                    ),
                                  ),
                                ],
                              ),
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
