import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Added
import 'package:http/http.dart' as http;        // Added
import 'dart:convert';                         // Added

import '../screens/home.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color brandYellow = Color(0xFFFFC21C);
  static const Color bgWhite = Colors.white;
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const double thickBorder = 3.5;
  static const double elementBorder = 2.5;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _lrnController;
  
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileImageUrl; // To store Cloudinary URL

  final _fs = FirestoreService();
  User? _user;

  // Cloudinary Details
  static const String cloudName = "dve0fnxd8";
  static const String uploadPreset = "profile_upload";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _lrnController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _user = AuthService().currentUser;
    if (_user == null) return;

    try {
      final doc = await _fs.getUser(_user!.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? _user!.displayName ?? 'User';
          _bioController.text = data['bio'] ?? '';
          _lrnController.text = data['lrn'] ?? '';
          _profileImageUrl = data['profileImage']; // Get existing image
          _isLoading = false;
        });
      } else {
        setState(() {
          _nameController.text = _user!.displayName ?? 'User';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _nameController.text = _user?.displayName ?? 'User';
        _isLoading = false;
      });
    }
  }

  // Cloudinary Upload Logic
  Future<String?> _uploadToCloudinary(XFile pickedFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final bytes = await pickedFile.readAsBytes();

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: pickedFile.name));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final data = json.decode(resData);
      return data['secure_url'];
    }
    return null;
  }

  // Image Picker Logic
  Future<void> _pickAndUploadImage() async {
    if (_user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isSaving = true); // Show loading while uploading photo
    try {
      final imageUrl = await _uploadToCloudinary(pickedFile);
      if (imageUrl == null) throw Exception("Upload failed");

      // Save to Firestore immediately
      await _fs.updateUserProfile(_user!.uid, profileImage: imageUrl);

      setState(() => _profileImageUrl = imageUrl);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo updated!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _isSaving = true);

    try {
      await _fs.updateUserProfile(
        _user!.uid,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        lrn: _lrnController.text.trim(),
      );
      await _user!.updateDisplayName(_nameController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _lrnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: brandYellow,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: brandYellow,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // TOP YELLOW SECTION
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            height: isKeyboardOpen ? size.height * 0.12 : size.height * 0.45,
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
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        ),
                      ),
                    ),
                  ),

                  if (!isKeyboardOpen) ...[
                    const Spacer(),
                    // INTEGRATED IMAGE UPLOAD GESTURE
                    // 🔥 UPDATED PROFILE IMAGE WITH EDIT OVERLAY
GestureDetector(
  onTap: _isEditing ? _pickAndUploadImage : null,
  child: Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: textBlack, width: 1.5),
    ),
    child: ClipOval(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Profile Image
          _profileImageUrl != null
              ? Image.network(
                  _profileImageUrl!,
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160,
                )
              : Image.network(
                  'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(_nameController.text)}&backgroundColor=transparent',
                  fit: BoxFit.contain,
                  width: 160,
                  height: 160,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80),
                ),

          // 2. The "Hover/Edit" Overlay (Only shows when editing)
          if (_isEditing)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 160,
              height: 160,
              color: Colors.black.withOpacity(0.4), // Dims the image
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 35,
              ),
            ),
            
          // 3. Loading indicator if uploading
          if (_isSaving && _isEditing)
            const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    ),
  ),
),
                    const Spacer(),
                    _buildProgressSection(),
                    const SizedBox(height: 25),
                  ]
                ],
              ),
            ),
          ),

          // BOTTOM WHITE SHEET
          Expanded(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: bgWhite,
                  border: Border(
                    top: BorderSide(color: textBlack, width: thickBorder),
                    left: BorderSide(color: textBlack, width: thickBorder),
                    right: BorderSide(color: textBlack, width: thickBorder),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25, 12, 25, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 60, height: 5,
                            decoration: BoxDecoration(color: textBlack, borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _isSaving
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                                )
                              : IconButton(
                                  onPressed: () async {
                                    if (_isEditing) await _saveProfile();
                                    setState(() => _isEditing = !_isEditing);
                                  },
                                  icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_outlined, color: textBlack, size: 28),
                                ),
                        ),

                        // Inputs
                        TextField(
                          controller: _nameController,
                          enabled: _isEditing,
                          style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                        Text(_user?.email ?? '', style: GoogleFonts.montserrat(fontSize: 14, color: textGrey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _bioController,
                          enabled: _isEditing,
                          maxLines: null,
                          style: GoogleFonts.montserrat(fontSize: 17, color: textGrey, height: 1.4),
                          decoration: InputDecoration(
                            border: _isEditing ? const UnderlineInputBorder() : InputBorder.none,
                            hintText: 'Write a short bio...',
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildChip('Notes'),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Text('LRN: ', style: GoogleFonts.montserrat(color: textGrey, fontSize: 17, fontWeight: FontWeight.w500)),
                            Expanded(
                              child: TextField(
                                controller: _lrnController,
                                enabled: _isEditing,
                                style: GoogleFonts.montserrat(color: textGrey, fontSize: 17, fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter LRN'),
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
          ),
        ],
      ),
    );
  }

  // --- Widgets preserved from your second code ---
  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: Column(
        children: [
          Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: bgWhite, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 8),
          Text('0%', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 18)),
          Text('Quarter 1', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 26, color: bgWhite)),
          Text('Progress', style: GoogleFonts.montserrat(color: bgWhite, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: bgWhite, shape: BoxShape.circle, border: Border.all(color: textBlack, width: elementBorder)),
        child: Icon(icon, color: textBlack, size: 28),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: textBlack, width: elementBorder)),
      child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }
}