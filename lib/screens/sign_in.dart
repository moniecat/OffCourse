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
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_emailError != null || _passwordError != null) {
      setState(() {
        _emailError = null;
        _passwordError = null;
      });
    }
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = "Email address is required.");
      return;
    }
    if (!email.contains('@')) {
      setState(() => _emailError = "Please enter a valid email address.");
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = "Password is required.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signIn(email, password);
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'user-not-found' || e.code == 'invalid-email') {
            _emailError = "The email you entered isn't connected to an account.";
          } 
          else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            _passwordError = "The password you entered is incorrect.";
          } 
          else {
            _emailError = "Login failed. Please try again.";
          }
        });
      }
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
          // Adjusted padding slightly for better fit on small screens
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/pics/logo2.png', width: 120, height: 120),
              const SizedBox(height: 10),
              // FIX: Wrapped in FittedBox to prevent clipping on small devices
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    fontSize: 52, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: -2
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                controller: _emailController,
                hintText: 'Email address',
                icon: Icons.person_outline,
                hasError: _emailError != null,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _onTextChanged(),
              ),
              if (_emailError != null) _buildErrorLabel(_emailError!),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                hasError: _passwordError != null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSignIn(),
                onChanged: (_) => _onTextChanged(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_passwordError != null) _buildErrorLabel(_passwordError!),

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
                          style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)
                        ),
                ),
              ),
              const SizedBox(height: 30),
              
              // FIX: Replaced Row with Wrap to prevent Right Overflow
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text("New here? ", style: GoogleFonts.montserrat(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: Text('Create account', style: GoogleFonts.montserrat(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorLabel(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline, color: Colors.red, size: 16),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: Colors.red, 
                fontSize: 13, 
                fontWeight: FontWeight.w700
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    required bool hasError,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
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
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.black, 
            width: 2.5
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.black, 
            width: 3.0
          ),
        ),
      ),
    );
  }
}