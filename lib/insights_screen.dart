import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // ✨ Map สำหรับแปลง Path รูปภาพให้เป็นชื่ออารมณ์
  static const Map<String, String> _moodLabels = {
    'assets/images/mood1.png': 'Crying',
    'assets/images/mood2.png': 'Happy',
    'assets/images/mood3.png': 'Super Angry',
    'assets/images/mood4.png': 'Tired',
    'assets/images/mood5.png': 'Not Pleased',
    'assets/images/mood6.png': 'Excited',
    'assets/images/mood7.png': 'Sad',
    'assets/images/mood8.png': 'Calm',
    'assets/images/mood9.png': 'Sleepy',
    'assets/images/mood10.png': 'Disappointed',
    'assets/images/mood11.png': 'Confused',
  };

  String _getAIAdvice(Map<String, double> stats, List<MapEntry<String, double>> sortedEntries) {
    if (stats.isEmpty) return "บันทึกอารมณ์วันนี้ เพื่อให้ Vibie ช่วยดูแลใจคุณนะคะ";

    final topMoodPath = sortedEntries.first.key;
    final topMoodLabel = _moodLabels[topMoodPath] ?? 'Good';
    
    double negativeScore = 0;
    stats.forEach((path, percentage) {
      if (path.contains('mood1') || path.contains('mood3') || 
          path.contains('mood7') || path.contains('mood10')) {
        negativeScore += percentage;
      }
    });

    if (negativeScore > 50) {
      return "ช่วงนี้ดูเหมือนหัวใจคุณจะแบกรับเรื่องหนักๆ ไว้เยอะเลยนะค๊ะ.. ไม่เป็นไรเลยค่ะที่จะรู้สึกเหนื่อย Vibie อยากบอกว่าคุณเก่งมากแล้วค่ะที่ผ่านมันมาได้ ลองหาของอร่อยๆ ทานหรือนอนพักผ่อนให้เต็มอิ่มนะคะ พรุ่งนี้ Vibie จะรอเริ่มต้นวันใหม่ไปพร้อมกับคุณค่ะ";
    } else if (topMoodLabel == 'Happy' || topMoodLabel == 'Excited') {
      return "ว้าว! พลังงานความสุขของคุณสดใสมากเลยค่ะ ช่วงนี้โลกดูเป็นสีชมพูไปหมดเลยนะคะเนี่ย รักษาความรู้สึกดีๆ แบบนี้ไว้นะคะ ลองจดบันทึกเรื่องที่ทำให้ยิ้มได้วันนี้ไว้สิคะ มันจะเป็นขุมพลังชั้นดีเวลาคุณเหนื่อยเลยค่ะ!";
    } else if (topMoodLabel == 'Tired' || topMoodLabel == 'Sleepy') {
      return "ร่างกายเริ่มส่งสัญญาณเตือนแล้วนะคะว่าต้องการการพักผ่อน ช่วงนี้ลองวางมือถือให้ห่างตัว แล้วนอนหลับให้เต็มอิ่มดูนะคะ คุณคู่ควรกับความผ่อนคลายที่สุดแล้วค่ะ Vibie เป็นกำลังใจให้พักผ่อนได้เต็มที่นะคะ";
    } else if (topMoodLabel == 'Calm' || topMoodLabel == 'Calm') {
      return "ใจของคุณดูสงบและมั่นคงมากเลยค่ะ Vibe แบบนี้แหละค่ะที่ยอดเยี่ยมที่สุด ลองนั่งสมาธิหรืออ่านหนังสือเล่มโปรดเพื่อเติมพลังใจให้เต็มร้อยต่อไปนะคะ วันนี้ทำได้ดีมากจริงๆ ค่ะ";
    } else {
      return "คุณกำลังทำได้ดีมากในการจัดการความรู้สึกของตัวเองค่ะ! แม้จะมีวันที่สับสนบ้าง แต่นั่นคือส่วนหนึ่งของการเติบโตนะคะ Vibie ภูมิใจในตัวคุณเสมอค่ะ ก้าวไปในจังหวะที่หัวใจคุณโอเคได้เลยนะคะ";
    }
  }

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
    if (total == 0) return {};
    return counts.map((path, moodCount) => MapEntry(path, (moodCount / total) * 100));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F2), // ขาวนวล
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Insights',
          style: GoogleFonts.itim(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('moods')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final stats = _calculateStats(snapshot.data!);
                if (stats.isEmpty) {
                  return Center(
                    child: Text('No data yet, start recording!', style: GoogleFonts.itim()),
                  );
                }

                final sortedEntries = stats.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final aiAdvice = _getAIAdvice(stats, sortedEntries);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vibie AI Mentor', style: GoogleFonts.itim(fontSize: 18, color: Colors.black54)),
                      const SizedBox(height: 15),
                      // --- AI ADVICE CARD ---
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFFB7B2).withOpacity(0.4), Colors.white],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xFFFFB7B2), size: 28),
                                const SizedBox(width: 10),
                                Text('Mental Health Summary', style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(aiAdvice, style: GoogleFonts.itim(fontSize: 16, height: 1.5, color: Colors.black87)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('Mood Distribution', style: GoogleFonts.itim(fontSize: 18, color: Colors.black54)),
                      const SizedBox(height: 25),
                      ...sortedEntries.map((entry) => _buildMoodBar(entry.key, _moodLabels[entry.key] ?? 'Mood', entry.value)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMoodBar(String imagePath, String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
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
                    Text(label, style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${percentage.toInt()}%', style: GoogleFonts.itim(fontSize: 14, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.black.withOpacity(0.05),
                    color: const Color(0xFFFFB7B2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}