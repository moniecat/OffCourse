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

  // --- SUCCESS FEEDBACK HELPER ---
  void _showSuccessSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2DCFA1), // Same Teal
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.black, width: 2.5),
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
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                    'Edit Question',
                    style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  _buildDialogField(label: 'Question', controller: questionController, icon: Icons.help_outline, maxLines: 3),
                  _buildDialogField(label: 'Option A', controller: optionAController, icon: Icons.looks_one_outlined),
                  _buildDialogField(label: 'Option B', controller: optionBController, icon: Icons.looks_two_outlined),
                  _buildDialogField(label: 'Option C', controller: optionCController, icon: Icons.looks_3_outlined),
                  _buildDialogField(label: 'Option D', controller: optionDController, icon: Icons.looks_4_outlined),
                  
                  _buildLabel('CORRECT ANSWER'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCorrect,
                        isExpanded: true,
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.black),
                        items: ['A', 'B', 'C', 'D']
                            .map((e) => DropdownMenuItem(value: e, child: Text('Option $e')))
                            .toList(),
                        onChanged: (val) => setDialogState(() => selectedCorrect = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                                  final q = questionController.text.trim();
                                  final a = optionAController.text.trim();
                                  final b = optionBController.text.trim();
                                  final c = optionCController.text.trim();
                                  final d = optionDController.text.trim();

                                  if (q.isEmpty || a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) return;

                                  setDialogState(() => isLoading = true);
                                  
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(dialogContext);

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
                                    
                                    navigator.pop();
                                    _showSuccessSnackBar(messenger, 'Question updated!');
                                    setState(() {});
                                  } catch (e) {
                                    // error
                                  } finally {
                                    if (mounted) setDialogState(() => isLoading = false);
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
            _showSuccessSnackBar(messenger, 'Question deleted successfully');
            setState(() {});
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red));
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
                    if (modules.isEmpty) return Center(child: Text("No modules found", style: TextStyle(color: textColor)));

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

        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
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
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF249780), size: 24),
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
          ),
        );
      },
    );
  }
}