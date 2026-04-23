import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F2), // สีขาวนวล Warm White
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account',
          style: GoogleFonts.itim(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // ส่วนแสดงข้อมูล User
            Row(
              children: [
                // รูปโปรไฟล์จาก Google
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB7B2).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    image: user?.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(user!.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? (user?.email != null ? user!.email!.split('@')[0] 
                      : 'Vibie User'),
                      style: GoogleFonts.itim(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3D3D4E),
                      ),
                    ),
                    Text(
                      user?.email ?? 'No email found',
                      style: GoogleFonts.itim(
                        fontSize: 14,
                        color: Colors.black38
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.black12),
            const SizedBox(height: 20),
            // ส่วนสถานะ Google Login & Logout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      width: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logged in with Google',
                      style: GoogleFonts.itim(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _handleLogout(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Log out',
                    style: GoogleFonts.itim(color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}