import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../providers/theme_provider.dart';
import '../widgets/admin_widgets.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  String _searchQuery = '';

  // Theme-aware getters
  Color get _borderColor => Theme.of(context).colorScheme.onSurface;
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _hintColor => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

  Future<void> _editCourse(Course course) async {
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description ?? '');
    final orderController = TextEditingController(text: course.order.toString());
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Course', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: InputDecoration(
                    labelText: 'Order',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final description = descriptionController.text.trim();
                      final order = int.tryParse(orderController.text.trim()) ?? 0;

                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Title is required', style: GoogleFonts.montserrat())),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      // Capture the Navigator and Messenger before the async gap
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await FirestoreService().updateCourse(course.id, title, description, order);
                        
                        // Check if the widget is still in the tree
                        if (!mounted) return;

                        navigator.pop(); // Close dialog
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Course updated', style: GoogleFonts.montserrat()),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {}); // Refresh list
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red),
                        );
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: Text('Update', style: GoogleFonts.montserrat()),
            ),
          ],
        ),
      ),
    );
  }

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
            setState(() {}); // Refresh list
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.all(color: _borderColor, width: 2.5),
          boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
        ),
        child: Icon(Icons.arrow_back, color: _borderColor, size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme changes
    context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Manage\nCourses',
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
                color: _textColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor, width: 2.5),
                boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: GoogleFonts.montserrat(color: _hintColor),
                  prefixIcon: Icon(Icons.search, color: _borderColor),
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: FirestoreService().getCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _borderColor));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading courses', style: GoogleFonts.montserrat()));
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
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor, width: 2.5),
                        boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Text(
                          course.title.toUpperCase(),
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16, color: _textColor),
                        ),
                        subtitle: Text(
                          course.description ?? 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: _hintColor),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 24),
                              onPressed: () => _editCourse(course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                              onPressed: () => _deleteCourse(course.id, course.title),
                            ),
                          ],
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