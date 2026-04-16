import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up.dart';
import 'home.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signIn(email, password);

      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        default:
          message = 'Sign in failed: ${e.message}';
      }
      if (!mounted) return;
      _showSnack(message);
    } catch (e) {
      if (!mounted) return;
      _showSnack('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pics/logo2.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: GoogleFonts.montserrat(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back! Please enter your\ndetails to sign in.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF424242),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Email Field - Moves to NEXT field
              _buildTextField(
                controller: _emailController,
                hintText: 'Email address',
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Password Field - Submits the form
              _buildTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSignIn(),
              ),

              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isLoading ? null : _handleSignIn,
                child: Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 5))],
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'Sign in',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are new? ",
                    style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                    },
                    child: Text(
                      'Create new',
                      style: GoogleFonts.montserrat(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(color: Colors.black38, fontSize: 18),
        prefixIcon: Icon(icon, color: Colors.black, size: 28),
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.black, width: 2.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
    );
  }
}