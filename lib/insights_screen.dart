import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  Map<String, double> _calculateStats(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final counts = <String, int>{};
    var total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final paths = (data['moodImagePaths'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList();

      for (final path in paths) {
        counts[path] = (counts[path] ?? 0) + 1;
        total++;
      }
    }

    if (total == 0) {
      return {};
    }

    return counts.map((path, moodCount) => MapEntry(path, (moodCount / total) * 100));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Insights',
          style: GoogleFonts.itim(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? _buildEmptyState(
              title: 'Please sign in first',
              subtitle: 'Insights needs authenticated user data.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('moods')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildEmptyState(
                    title: 'ไม่สามารถโหลดข้อมูลได้ตอนนี้',
                    subtitle: 'ลองใหม่อีกครั้งในภายหลัง',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = _calculateStats(snapshot.data!);
                return stats.isEmpty
                    ? _buildEmptyState(
                        title: 'ยังไม่มีข้อมูลการวิเคราะห์ในขณะนี้',
                        subtitle: 'ลองบันทึกอารมณ์วันแรกของคุณดูนะ!',
                      )
                    : _buildInsightContent(stats);
              },
            ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 80, color: Colors.black12),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.itim(fontSize: 18, color: Colors.black45),
          ),
          Text(
            subtitle,
            style: GoogleFonts.itim(fontSize: 14, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightContent(Map<String, double> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: GoogleFonts.itim(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB7B2).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFFFB7B2), size: 35),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vibie AI Insights',
                        style: GoogleFonts.itim(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('AI กำลังวิเคราะห์รูปแบบอารมณ์ของคุณ...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Mood Frequency',
            style: GoogleFonts.itim(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 25),
          ...stats.entries.map((entry) {
            String label =
                entry.key.split('/').last.split('.').first.replaceAll('mood', 'Mood ');
            return _buildMoodBar(
              label,
              entry.value,
              const Color(0xFFFFB7B2),
              entry.key,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String label, double percentage, Color color, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Image.asset(imagePath, width: 35, height: 35),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${percentage.toInt()}%',
                      style: const TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.black.withValues(alpha: 0.05),
                  color: color,
                  minHeight: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
