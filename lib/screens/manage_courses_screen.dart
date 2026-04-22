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
                content: Text('Course deleted', style: GoogleFonts.montserrat()),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  // Exact same back button from your AddCourseScreen
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BOLD HEADER (Matches "Add Course" style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Manage\nCourses',
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
                color: darkBorder,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // STYLED SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.black26),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // LIST AREA
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: FirestoreService().getCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }

                final filteredCourses = snapshot.data?.where((course) =>
                  course.title.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList() ?? [];

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Text('No courses found.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Text(
                          course.title.toUpperCase(),
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        subtitle: Text(
                          course.description ?? 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                          onPressed: () => _deleteCourse(course.id, course.title),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}