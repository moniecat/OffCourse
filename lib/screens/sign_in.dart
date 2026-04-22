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
  String? _errorMessage;
  bool _suggestSignUp = false; // Flag for "Account not found"

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Clears errors when the user starts typing again
  void _onTextChanged() {
    if (_errorMessage != null || _suggestSignUp) {
      setState(() {
        _errorMessage = null;
        _suggestSignUp = false;
      });
    }
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
        _suggestSignUp = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestSignUp = false;
    });

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
      bool suggest = false;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account exists for this email.';
          suggest = true;
          break;
        case 'wrong-password':
        case 'invalid-credential':
          // invalid-credential is the default for new Firebase security rules
          message = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = message;
          _suggestSignUp = suggest;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            children: [
              Image.asset(
                'assets/pics/logo2.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
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
              // Text(
              //   'Welcome back! Please enter your\ndetails to sign in.',
              //   textAlign: TextAlign.center,
              //   style: GoogleFonts.montserrat(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w600,
              //     color: const Color(0xFF424242),
              //     height: 1.3,
              //   ),
              // ),
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: _emailController,
                hintText: 'Email address',
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _onTextChanged(),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSignIn(),
                onChanged: (_) => _onTextChanged(),
              ),

              // DYNAMIC ERROR BANNER
              if (_errorMessage != null) _buildErrorBanner(),

              const SizedBox(height: 30),

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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade900, width: 2.5),
        boxShadow: [BoxShadow(color: Colors.red.shade900.withValues(alpha: 0.1), offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.montserrat(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (_suggestSignUp) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "REGISTER THIS EMAIL",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ]
        ],
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
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
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