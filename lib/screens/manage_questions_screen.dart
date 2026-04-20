import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';
import '../widgets/admin_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  String? _selectedCourseId;
  String? _selectedModuleId;
  List<Map<String, dynamic>> _modules = [];
  String _searchQuery = '';

  Future<void> _deleteQuestion(String courseId, String moduleId, String questionId) async {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Question',
        content: 'Are you sure you want to delete this question? This action cannot be undone.',
        onConfirm: () async {
          try {
            await FirestoreService().deleteQuestion(courseId, moduleId, questionId);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
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
          _selectedCourseId ??= courses.first.id;

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
                    _selectedModuleId = null;
                    _searchQuery = '';
                  });
                },
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _selectedCourseId != null ? FirestoreService().getModules(_selectedCourseId!) : Future.value([]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: AdminEmptyState(
                        title: 'No Modules Found',
                        subtitle: 'Add modules to this course first',
                        icon: Icons.layers_outlined,
                      ),
                    );
                  }

                  _modules = snapshot.data!;
                  if (_selectedModuleId == null && _modules.isNotEmpty) {
                    _selectedModuleId = _modules.first['id'];
                  }

                  return AdminDropdown<String>(
                    label: 'SELECT MODULE',
                    hint: 'Choose a module',
                    value: _selectedModuleId,
                    items: _modules.map<DropdownMenuItem<String>>((module) {
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
                  );
                },
              ),
              if (_selectedModuleId != null)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
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

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return AdminEmptyState(
                          title: 'No Questions Found',
                          subtitle: 'Add your first question to this module',
                          icon: Icons.quiz_outlined,
                        );
                      }

                      final allQuestions = snapshot.data!;
                      final filteredQuestions = allQuestions
                          .where((question) =>
                              (question['question'] ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              (question['correctAnswer'] ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
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
                                        subtitle:
                                            'Answer: ${question['correctAnswer'] ?? 'N/A'}',
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
