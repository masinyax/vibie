import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showEmailSignIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // เพื่อให้ดันขึ้นตามคีย์บอร์ด
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
            
            // ช่องกรอก Email (รองรับ Autofill)
            TextField(
              autofillHints: const [AutofillHints.email], // เปิดระบบ Autofill ของเครื่อง
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
            
            // ปุ่มยืนยัน
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
      backgroundColor: const Color(0xFFFDFDFD), // พื้นหลังขาวนวล
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Container(
                child: Image.asset('assets/images/mood1.png', // ใช้รูปอารมณ์ที่มีความสุขที่สุดมาโชว์
                width: 150,
                height: 150,
              ),
              ),
              const SizedBox(height: 30),
              
              // 2. ชื่อแอปและคำโปรย
              Text(
                'Vibie',
                style: GoogleFonts.itim(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3D3D4E),
                ),
              ),
              Text(
                'Your little space for big feelings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              const Spacer(),

              // 3. ปุ่ม Login ด้วย Email
              _buildLoginButton(
                onPressed: () => _showEmailSignIn(context),
                iconWidget: const Icon(Icons.mail_outline_rounded, color: Colors.black87),
                label: 'Continue with Email',
                color: const Color(0xFFFFB7B2), // ชมพูพาสเทล
              ),
              const SizedBox(height: 15),

              // 4. ปุ่ม Login ด้วย Google (โชว์ความโปร)
              _buildLoginButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                iconWidget: Image.asset('assets/images/google.png',
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
      ),
    );
  }

  // Widget ช่วยสร้างปุ่ม Login
  Widget _buildLoginButton({
    required VoidCallback onPressed,
    required Widget iconWidget,
    required String label,
    required Color color,
    bool isBordered = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isBordered ? const BorderSide(color: Colors.black12) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}