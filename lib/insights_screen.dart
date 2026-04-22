import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // สำคัญ: ต้อง import เพื่อให้เห็น savedMoods

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  Map<String, double> _calculateStats() {
    if (savedMoods.isEmpty) return {};
    
    Map<String, int> counts = {};
    int total = 0;

    savedMoods.forEach((date, paths) {
      for (var path in paths) {
        counts[path] = (counts[path] ?? 0) + 1;
        total++;
      }
    });

    return counts.map((path, count) => MapEntry(path, (count / total) * 100));
  }

  @override
  Widget build(BuildContext context) {
    // เรียกใช้ฟังก์ชันคำนวณ
    final stats = _calculateStats();

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
      body: savedMoods.isEmpty 
        ? _buildEmptyState() // ถ้าไม่มีข้อมูล ให้โชว์หน้าว่างที่ออกแบบไว้
        : _buildInsightContent(stats), // ถ้ามีข้อมูล ค่อยโชว์กราฟวิเคราะห์
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.black12),
          const SizedBox(height: 20),
          Text(
            'ยังไม่มีข้อมูลการวิเคราะห์ในขณะนี้',
            style: GoogleFonts.itim(fontSize: 18, color: Colors.black45),
          ),
          Text(
            'ลองบันทึกอารมณ์วันแรกของคุณดูนะ!',
            style: GoogleFonts.itim(fontSize: 14, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  // --- ส่วนหน้าตาตอนที่มีข้อมูลแล้ว ---
  Widget _buildInsightContent(Map<String, double> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Summary', style: GoogleFonts.itim(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB7B2).withOpacity(0.2),
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
                      Text('Vibie AI Insights', style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('AI กำลังวิเคราะห์รูปแบบอารมณ์ของคุณ...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text('Mood Frequency', style: GoogleFonts.itim(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 25),
          ...stats.entries.map((entry) {
            // ดึงชื่ออารมณ์จากชื่อไฟล์
            String label = entry.key.split('/').last.split('.').first.replaceAll('mood', 'Mood ');
            return _buildMoodBar(label, entry.value, const Color(0xFFFFB7B2), entry.key);
          }).toList(),
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
                    Text('${percentage.toInt()}%', style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.black.withOpacity(0.05),
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