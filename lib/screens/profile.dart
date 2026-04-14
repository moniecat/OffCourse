import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Assumed imports based on your project structure
import '../screens/home.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Neo-Brutalist Theme Constants
  static const Color brandYellow = Color(0xFFFFC21C);
  static const Color bgWhite = Colors.white;
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const double thickBorder = 3.5;
  static const double elementBorder = 2.5;

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileImageUrl;

  final _fs = FirestoreService();
  User? _user;

  static const String cloudName = "dve0fnxd8";
  static const String uploadPreset = "profile_upload";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _loadProfile() async {
    _user = AuthService().currentUser;
    if (_user == null) return;
    try {
      final doc = await _fs.getUser(_user!.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = _toTitleCase(data['name'] ?? _user!.displayName ?? 'User');
          _bioController.text = data['bio'] ?? '';
          _profileImageUrl = data['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _nameController.text = _toTitleCase(_user!.displayName ?? 'User');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile == null) return;

    setState(() => _isSaving = true);
    try {
      final imageUrl = await _uploadToCloudinary(pickedFile);
      if (imageUrl == null) throw Exception("Upload failed");
      await _fs.updateUserProfile(_user!.uid, profileImage: imageUrl);
      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String?> _uploadToCloudinary(XFile file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final bytes = await file.readAsBytes();
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'profile.jpg'));
    final response = await request.send();
    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final data = json.decode(resData);
      return data['secure_url'] as String?;
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _isSaving = true);
    try {
      final formattedName = _toTitleCase(_nameController.text.trim());
      await _fs.updateUserProfile(_user!.uid, name: formattedName, bio: _bioController.text.trim());
      await _user!.updateDisplayName(formattedName);
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      if (mounted) _nameController.text = formattedName;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (_isLoading) {
      return const Scaffold(
          backgroundColor: brandYellow,
          body: Center(child: CircularProgressIndicator(color: textBlack)));
    }

    return Scaffold(
      backgroundColor: brandYellow,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── 1. BACKGROUND TEXTURE (Dot Grid) ──
          Positioned.fill(
            bottom: size.height * 0.5,
            child: CustomPaint(painter: DotGridPainter()),
          ),

          // ── 3. MAIN CONTENT COLUMN ──
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isKeyboardOpen ? size.height * 0.15 : size.height * 0.45,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildCircularButton(
                            Icons.chevron_left,
                            onTap: () => Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                          ),
                        ),
                      ),
                      if (!isKeyboardOpen) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: _isEditing ? _pickAndUploadImage : null,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgWhite,
                                border: Border.all(color: textBlack, width: 3),
                                boxShadow: const [BoxShadow(color: textBlack, offset: Offset(8, 8))]),
                            child: ClipOval(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _profileImageUrl != null
                                      ? Image.network(_profileImageUrl!,
                                          fit: BoxFit.cover, width: 180, height: 180)
                                      : Image.network(
                                          'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(_nameController.text)}',
                                          fit: BoxFit.contain,
                                          width: 180,
                                          height: 180),
                                  if (_isEditing)
                                    Container(
                                        color: Colors.black45,
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 40)),
                                  if (_isSaving && _isEditing) const CircularProgressIndicator(color: brandYellow),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                      ]
                    ],
                  ),
                ),
              ),

              // ── BOTTOM SHEET ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: bgWhite,
                    border: Border(top: BorderSide(color: textBlack, width: thickBorder)),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25, 45, 25, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          readOnly: !_isEditing,
                          maxLines: 1,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.montserrat(
                              fontSize: 30, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: -1.0),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                        ),
                        const SizedBox(height: 4),
                        Text(_user?.email ?? '',
                            style: GoogleFonts.montserrat(fontSize: 14, color: textGrey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 35),
                        Text("ABOUT ME",
                            style: GoogleFonts.montserrat(
                                fontSize: 12, fontWeight: FontWeight.w900, color: textBlack, letterSpacing: 2.0)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgWhite,
                            border: Border.all(color: textBlack, width: elementBorder),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: textBlack, offset: Offset(4, 4))],
                          ),
                          child: TextField(
                            controller: _bioController,
                            readOnly: !_isEditing,
                            maxLines: null,
                            style: GoogleFonts.montserrat(fontSize: 16, color: textBlack, height: 1.5, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Share your story...',
                                hintStyle: TextStyle(color: Colors.black26)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 4. FLOATING ACTION BUTTON ──
          if (!isKeyboardOpen)
            Positioned(
              top: (size.height * 0.45) - 30,
              right: 40,
              child: GestureDetector(
                onTap: () async {
                  if (_isEditing) await _saveProfile();
                  if (mounted) setState(() => _isEditing = !_isEditing);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.greenAccent : brandYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: textBlack, width: thickBorder),
                    boxShadow: const [BoxShadow(color: textBlack, offset: Offset(4, 4))],
                  ),
                  child: _isSaving
                      ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(color: textBlack, strokeWidth: 3))
                      : Icon(_isEditing ? Icons.check : Icons.edit, color: textBlack, size: 28),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: bgWhite, shape: BoxShape.circle, border: Border.all(color: textBlack, width: elementBorder)),
        child: Icon(icon, color: textBlack, size: 28),
      ),
    );
  }
}

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // Changed withOpacity(0.12) to withValues(alpha: 0.12)
      ..color = Colors.black.withValues(alpha: 0.12) 
      ..strokeWidth = 2.0;

    const double gap = 25.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}