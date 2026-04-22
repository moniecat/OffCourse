import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../widgets/admin_widgets.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  String? _selectedCourseId;
  String? _selectedModuleId;
  String _searchQuery = '';

  // Helper to delete questions
  Future<void> _deleteQuestion(String courseId, String moduleId, String questionId) async {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Question',
        content: 'Are you sure you want to delete this question? This action cannot be undone.',
        onConfirm: () async {
          try {
            await FirestoreService().deleteQuestion(courseId, moduleId, questionId);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Question deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the UI
            setState(() {});
          } catch (e) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to delete question'),
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
          'Manage Questions',
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
              subtitle: 'Create a course first to add questions',
              icon: Icons.library_add_rounded,
            );
          }

          final courses = snapshot.data!;
          // Set initial course if none is selected
          _selectedCourseId ??= courses.first.id;

          return Column(
            children: [
              // 1. COURSE DROPDOWN
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
                    _selectedModuleId = null; // Reset module so logic below picks the first one
                    _searchQuery = '';
                  });
                },
              ),
              const SizedBox(height: 12),

              // 2. MODULE DROPDOWN & QUESTION LIST
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  // Using a unique key ensures this reloads completely when the course changes
                  key: ValueKey(_selectedCourseId),
                  future: FirestoreService().getModules(_selectedCourseId!),
                  builder: (context, moduleSnapshot) {
                    if (moduleSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final modules = moduleSnapshot.data ?? [];
                    if (modules.isEmpty) {
                      return AdminEmptyState(
                        title: 'No Modules Found',
                        subtitle: 'Add modules to this course first',
                        icon: Icons.layers_outlined,
                      );
                    }

                    // Handle Module ID validation/selection
                    bool currentIdIsValid = modules.any((m) => m['id'] == _selectedModuleId);
                    if (!currentIdIsValid) {
                      _selectedModuleId = modules.first['id'];
                    }

                    return Column(
                      children: [
                        AdminDropdown<String>(
                          label: 'SELECT MODULE',
                          hint: 'Choose a module',
                          value: _selectedModuleId,
                          items: modules.map<DropdownMenuItem<String>>((module) {
                            return DropdownMenuItem<String>(
                              value: module['id'] as String,
                              child: Text(module['title'] ?? 'Untitled'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedModuleId = value;
                              _searchQuery = '';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // 3. QUESTIONS LIST
                        Expanded(
                          child: _buildQuestionsList(),
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

  Widget _buildQuestionsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Key is essential: it tells Flutter to restart this Future when IDs change
      key: ValueKey('$_selectedCourseId-$_selectedModuleId'),
      future: FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId!)
          .collection('modules')
          .doc(_selectedModuleId!)
          .collection('questions')
          .get()
          .then((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allQuestions = snapshot.data ?? [];
        if (allQuestions.isEmpty) {
          return AdminEmptyState(
            title: 'No Questions Found',
            subtitle: 'Add your first question to this module',
            icon: Icons.quiz_outlined,
          );
        }

        final filteredQuestions = allQuestions
            .where((question) =>
                (question['question'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (question['correctAnswer'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Column(
          children: [
            AdminSearchBar(
              hint: 'Search questions...',
              value: _searchQuery,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            Expanded(
              child: filteredQuestions.isEmpty
                  ? AdminEmptyState(
                      title: 'No Results',
                      subtitle: 'Try searching with different keywords',
                      icon: Icons.search_rounded,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final question = filteredQuestions[index];
                        return AdminListItem(
                          title: question['question'] ?? 'Untitled',
                          subtitle: 'Answer: ${question['correctAnswer'] ?? 'N/A'}',
                          badge: '${index + 1}/${filteredQuestions.length}',
                          accentColor: const Color(0xFF00CBA9),
                          onDelete: () => _deleteQuestion(
                            _selectedCourseId!,
                            _selectedModuleId!,
                            question['id'],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}