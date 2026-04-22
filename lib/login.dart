import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // --- Logic สำหรับ Google Sign-In ---
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      debugPrint("Login Error: $error");
    }
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _continueWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } else {
        _showMessage(e.message ?? 'Email sign-in failed');
        return;
      }
    } catch (_) {
      _showMessage('Email sign-in failed');
      return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Google sign-in failed');
    } catch (e) {
      _showMessage('Google sign-in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              style: GoogleFonts.itim(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Enter your email to continue with Vibie.',
              style: GoogleFonts.itim(color: Colors.black45),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: emailController,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
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
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _continueWithEmail(
                        emailController.text,
                        passwordController.text,
                      );
                    },
              iconWidget: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black87,
              ),
              label: 'Next',
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
          // 1. ✨ ส่วนแบคกราวด์รูป home.png (เหล่าตัวการ์ตูน)
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // ปรับความจางเพื่อให้ปุ่มและชื่อแอปยังอ่านง่าย
              child: Image.asset(
                'assets/images/home.png', // รูป Emotions Back To School ที่คุณตั้งชื่อใหม่
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. เนื้อหาหน้า Login
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // 3. ✨ ชื่อแอป Vibie ตัวใหญ่ๆ แบบ Mooda
                  Text(
                    'Vibie',
                    style: GoogleFonts.itim(
                      fontSize: 80, // ใหญ่สะใจแบบ Mooda เลยครับ
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

                  // 4. ปุ่ม Login
                  _buildLoginButton(
                    onPressed: () => _showEmailSignIn(context),
                    iconWidget: const Icon(Icons.mail_outline_rounded, color: Colors.black87),
                    label: 'Continue with Email',
                    color: const Color(0xFFFFB7B2),
                  ),
                  const SizedBox(height: 15),
                  _buildLoginButton(
                    onPressed: () => _handleGoogleSignIn(context),
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
                  
                  Text(
                    'By continuing, you are agreeing to create an account.',
                    style: GoogleFonts.itim(fontSize: 12, color: Colors.black26),
                  ),
                ],
              ),
            ),
          ),
        ],
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/mood1.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Vibie',
                    style: GoogleFonts.itim(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3D3D4E),
                    ),
                  ),
                  const Text(
                    'Your little space for big feelings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                  const Spacer(),
                  _buildLoginButton(
                    onPressed: _isLoading ? null : () => _showEmailSignIn(context),
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
                      width: 16,
                      height: 16,
                    ),
                    label: 'Continue with Google',
                    color: Colors.white,
                    isBordered: true,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (_isLoading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
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
            side: isBordered ? const BorderSide(color: Colors.black12) : BorderSide.none,
            borderRadius: BorderRadius.circular(15),
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
            Text(label, style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
