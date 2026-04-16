import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();
  final _fs = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signUp(email, password);
      if (user != null) {
        await user.updateDisplayName(name);
        _fs.addUser(user.uid, name, email, role: 'student');
        await _auth.signOut();
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed: ${e.message}';
      if (!mounted) return;
      _showSnack(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Text('Sign up', style: GoogleFonts.montserrat(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.black)),
            const SizedBox(height: 45),
            
            // Name -> Next
            _buildTextField(
              controller: _nameController,
              hintText: 'Full Name',
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Email -> Next
            _buildTextField(
              controller: _emailController,
              hintText: 'Email address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Password -> Sign Up (Done)
            _buildTextField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSignUp(),
            ),
            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: _isLoading ? null : _handleSignUp,
              child: Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 5))],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text('Sign up', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 35),
            // ... rest of your code
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      cursorColor: Colors.black,
      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
        prefixIcon: Padding(padding: const EdgeInsets.only(left: 15, right: 10), child: Icon(icon, color: Colors.black, size: 26)),
        contentPadding: const EdgeInsets.symmetric(vertical: 22),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.black, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
      ),
    );
  }
}