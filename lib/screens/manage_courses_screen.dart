import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../widgets/admin_widgets.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  String _searchQuery = '';

  Future<void> _deleteCourse(String courseId, String courseName) async {
    // Capture messenger state before async operations
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Course',
        content: 'Are you sure you want to delete "$courseName"?\nThis will also delete all modules and questions.',
        onConfirm: () async {
          try {
            await FirestoreService().deleteCourse(courseId);
            
            if (!mounted) return;
            
            messenger.showSnackBar(
              SnackBar(
                content: Text('Course "$courseName" deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to delete course'),
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
          'Manage Courses',
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
              subtitle: 'Create your first course to get started',
              icon: Icons.library_add_rounded,
            );
          }

          final allCourses = snapshot.data!;
          final filteredCourses = allCourses
              .where((course) =>
                  course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (course.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
              .toList();

          return Column(
            children: [
              AdminSearchBar(
                hint: 'Search courses...',
                value: _searchQuery,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              Expanded(
                child: filteredCourses.isEmpty
                    ? AdminEmptyState(
                        title: 'No Results',
                        subtitle: 'Try searching with different keywords',
                        icon: Icons.search_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          return AdminListItem(
                            title: course.title,
                            subtitle: course.description ?? 'No description',
                            badge: '${allCourses.indexOf(course) + 1}/${allCourses.length}',
                            accentColor: const Color(0xFF00CBA9),
                            onDelete: () => _deleteCourse(course.id, course.title),
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