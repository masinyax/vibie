import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // --- Logic สำหรับ Google Sign-In ---
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      debugPrint("Login Error: $error");
    }
  }

  void _showEmailSignIn(BuildContext context) {
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
          left: 30, right: 30, top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back!', style: GoogleFonts.itim(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('Enter your email to continue with Vibie.', style: GoogleFonts.itim(color: Colors.black45)),
            const SizedBox(height: 25),
            TextField(
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
                filled: true,
                fillColor: Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              iconWidget: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
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
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onPressed,
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
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}