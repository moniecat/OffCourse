import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final _fs = FirestoreService();
  User? _user;

  String? _profileImageUrl;

  // 🔥 YOUR CLOUDINARY DETAILS
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
          _profileImageUrl = data['profileImage'];
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

  // ☁️ CLOUDINARY UPLOAD
 Future<String?> _uploadToCloudinary(XFile pickedFile) async {
  const cloudName = "dve0fnxd8";
  const uploadPreset = "profile_upload";

  final url = Uri.parse(
    "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
  );

  final bytes = await pickedFile.readAsBytes();

  final request = http.MultipartRequest("POST", url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: pickedFile.name,
      ),
    );

  final response = await request.send();

  if (response.statusCode == 200) {
    final resData = await response.stream.bytesToString();
    final data = json.decode(resData);
    return data['secure_url'];
  } else {
    return null;
  }
}

  // 📸 PICK + UPLOAD IMAGE
  Future<void> _pickAndUploadImage() async {
  if (_user == null) return;

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;

  try {
    final imageUrl = await _uploadToCloudinary(pickedFile);

    if (imageUrl == null) throw Exception("Upload failed");

    await _fs.updateUserProfile(
      _user!.uid,
      profileImage: imageUrl,
    );

    setState(() {
      _profileImageUrl = imageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload failed: $e')),
    );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: brandYellow,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: brandYellow,
      body: Column(
        children: [
          const SizedBox(height: 50),

          // 🔥 PROFILE IMAGE
          GestureDetector(
            onTap: _isEditing ? _pickAndUploadImage : null,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: textBlack, width: 2),
              ),
              child: ClipOval(
                child: _profileImageUrl != null
                    ? Image.network(
                        _profileImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(_nameController.text)}',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle_outline : Icons.edit_outlined,
              size: 30,
            ),
            onPressed: () async {
              if (_isEditing) await _saveProfile();
              setState(() => _isEditing = !_isEditing);
            },
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  TextField(
                    controller: _lrnController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'LRN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}