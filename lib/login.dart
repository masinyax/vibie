import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _continueWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showMessage('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        } catch (createError) {
          _showMessage('Could not create account: $createError');
        }
      } 
      else {
        _showMessage(e.message ?? 'Login failed');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // ล้าง session เก่า
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      _showMessage('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showEmailSignIn(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDFDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 30,
          right: 30,
          top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: GoogleFonts.itim(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Enter email to continue with Vibie.',
              style: GoogleFonts.itim(color: Colors.black45),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.alternate_email),
                filled: true,
                fillColor: Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildLoginButton(
              onPressed: () {
                Navigator.pop(context);
                _continueWithEmail(
                  emailController.text,
                  passwordController.text,
                );
              },
              iconWidget: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black87,
              ),
              label: 'Continue',
              color: const Color(0xFFFFB7B2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/home.png', fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  Text(
                    'Vibie',
                    style: GoogleFonts.itim(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3D3D4E),
                      letterSpacing: -2.0,
                    ),
                  ),
                  Text(
                    'Your little space for big feelings.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.itim(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(flex: 3),

                  _buildLoginButton(
                    onPressed: _isLoading
                        ? null
                        : () => _showEmailSignIn(context),
                    iconWidget: const Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.black87,
                    ),
                    label: 'Continue with Email',
                    color: const Color(0xFFFFB7B2),
                  ),
                  const SizedBox(height: 15),
                  _buildLoginButton(
                    onPressed: _isLoading ? null : _continueWithGoogle,
                    iconWidget: Image.asset(
                      'assets/images/google.png',
                      width: 22,
                      height: 22,
                    ),
                    label: 'Continue with Google',
                    color: Colors.white,
                    isBordered: true,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB7B2)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback? onPressed,
    required Widget iconWidget,
    required String label,
    required Color color,
    bool isBordered = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isBordered
                ? const BorderSide(color: Colors.black12)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.itim(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
