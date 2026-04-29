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

  Future<void> _editQuestion(String courseId, String moduleId, Map<String, dynamic> question) async {
    final questionController = TextEditingController(text: question['question'] ?? '');
    final optionAController = TextEditingController(text: question['optionA'] ?? '');
    final optionBController = TextEditingController(text: question['optionB'] ?? '');
    final optionCController = TextEditingController(text: question['optionC'] ?? '');
    final optionDController = TextEditingController(text: question['optionD'] ?? '');
    String? selectedCorrect = question['correctAnswer'] ?? 'A';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Question', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionAController,
                  decoration: InputDecoration(
                    labelText: 'Option A',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionBController,
                  decoration: InputDecoration(
                    labelText: 'Option B',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionCController,
                  decoration: InputDecoration(
                    labelText: 'Option C',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: optionDController,
                  decoration: InputDecoration(
                    labelText: 'Option D',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.montserrat(),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedCorrect,
                  items: ['A', 'B', 'C', 'D']
                      .map((e) => DropdownMenuItem(value: e, child: Text('Correct Answer: $e')))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedCorrect = val),
                  isExpanded: true,
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
                      final q = questionController.text.trim();
                      final a = optionAController.text.trim();
                      final b = optionBController.text.trim();
                      final c = optionCController.text.trim();
                      final d = optionDController.text.trim();

                      if (q.isEmpty || a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('All fields required', style: GoogleFonts.montserrat())),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      // Capture Navigator and Messenger before async gap
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await FirestoreService().updateQuestion(
                          courseId: courseId,
                          moduleId: moduleId,
                          questionId: question['id'],
                          questionType: 'mcq',
                          question: q,
                          optionA: a,
                          optionB: b,
                          optionC: c,
                          optionD: d,
                          correctAnswer: selectedCorrect ?? 'A',
                        );

                        if (!mounted) return;

                        navigator.pop(); // Close dialog
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Question updated', style: GoogleFonts.montserrat()),
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

  Future<void> _deleteQuestion(String courseId, String moduleId, String questionId) async {
    final messenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: 'Delete Question',
        content: 'Are you sure you want to delete this question?',
        onConfirm: () async {
          try {
            await FirestoreService().deleteQuestion(courseId, moduleId, questionId);
            
            if (!mounted) return;

            messenger.showSnackBar(
              SnackBar(
                content: Text('Question deleted', style: GoogleFonts.montserrat()), 
                backgroundColor: Colors.green
              )
            );
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red)
            );
          }
        },
      ),
    );
  }

  Widget _buildBackButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: iconColor, width: 2.5),
          boxShadow: [BoxShadow(color: iconColor, offset: const Offset(4, 4))],
        ),
        child: Icon(Icons.arrow_back, color: iconColor, size: 26),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
    );
  }

  Widget _buildNeoDropdown<T>({required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor, width: 2.5),
        boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: textColor),
          style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w700, fontSize: 16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : darkBorder;
    final mutedTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
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
            return Center(child: CircularProgressIndicator(color: textColor));
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) return Center(child: Text("No courses found", style: TextStyle(color: textColor)));
          _selectedCourseId ??= courses.first.id;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Manage\nQuestions',
                  style: GoogleFonts.montserrat(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.5,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SELECT COURSE'),
                    const SizedBox(height: 10),
                    _buildNeoDropdown<String>(
                      value: _selectedCourseId,
                      items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title.toUpperCase()))).toList(),
                      onChanged: (val) => setState(() {
                        _selectedCourseId = val;
                        _selectedModuleId = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  key: ValueKey(_selectedCourseId),
                  future: FirestoreService().getModules(_selectedCourseId!),
                  builder: (context, modSnap) {
                    if (modSnap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: textColor));
                    
                    final modules = modSnap.data ?? [];
                    if (modules.isEmpty) return Center(child: Text("No modules in this course", style: TextStyle(color: textColor)));

                    _selectedModuleId ??= modules.first['id'];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('SELECT MODULE'),
                              const SizedBox(height: 10),
                              _buildNeoDropdown<String>(
                                value: _selectedModuleId,
                                items: modules.map((m) => DropdownMenuItem(value: m['id'] as String, child: Text(m['title'].toString().toUpperCase()))).toList(),
                                onChanged: (val) => setState(() => _selectedModuleId = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: textColor, width: 2.5),
                              boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
                            ),
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Search questions...',
                                hintStyle: TextStyle(color: mutedTextColor),
                                prefixIcon: Icon(Icons.search, color: textColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Expanded(child: _buildQuestionsList()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return FutureBuilder<List<Map<String, dynamic>>>(
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
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: textColor));

        final questions = snapshot.data?.where((q) =>
          (q['question'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList() ?? [];

        if (questions.isEmpty) {
          return Center(child: Text('No questions found.', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textColor)));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final q = questions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2D2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: textColor, width: 2.5),
                boxShadow: [BoxShadow(color: textColor, offset: const Offset(4, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(q['question'] ?? 'UNTITLED', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor)),
                subtitle: Text('Correct: ${q['correctAnswer']}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: isDark ? Colors.lightGreen[400] : Colors.green[700])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 24),
                      onPressed: () => _editQuestion(_selectedCourseId!, _selectedModuleId!, q),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                      onPressed: () => _deleteQuestion(_selectedCourseId!, _selectedModuleId!, q['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}