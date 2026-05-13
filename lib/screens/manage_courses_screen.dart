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

  // --- SUCCESS FEEDBACK HELPER ---
  void _showSuccessSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2DCFA1), // Teal
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER: Custom Text Field (Neubrutalism Style) ---
  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey, size: 22),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2.5),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: Custom Dialog Button ---
  Widget _buildDialogButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 18, color: textColor),
          ),
        ),
      ),
    );
  }

  Future<void> _editCourse(Course course) async {
    final titleController = TextEditingController(text: course.title);
    final descriptionController = TextEditingController(text: course.description ?? '');
    final orderController = TextEditingController(text: course.order.toString());
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 6))],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Course',
                    style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  _buildDialogField(label: 'Title', controller: titleController, icon: Icons.title),
                  _buildDialogField(label: 'Description', controller: descriptionController, icon: Icons.description_outlined, maxLines: 3),
                  _buildDialogField(label: 'Order', controller: orderController, icon: Icons.format_list_numbered, keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          text: 'Cancel',
                          color: Colors.white,
                          textColor: Colors.grey[600]!,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDialogButton(
                          text: isLoading ? '...' : 'Update',
                          color: const Color(0xFF2DCFA1),
                          textColor: Colors.white,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final title = titleController.text.trim();
                                  final description = descriptionController.text.trim();
                                  final order = int.tryParse(orderController.text.trim()) ?? 0;

                                  if (title.isEmpty) return;

                                  setDialogState(() => isLoading = true);
                                  
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(dialogContext);

                                  try {
                                    await FirestoreService().updateCourse(course.id, title, description, order);
                                    
                                    if (!mounted) return;
                                    
                                    navigator.pop();
                                    _showSuccessSnackBar(messenger, 'Course updated!');
                                    setState(() {});
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setDialogState(() => isLoading = false);
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
            _showSuccessSnackBar(messenger, 'Course deleted successfully');
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
    context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent, 
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

                return ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
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
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF249780), size: 24),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}