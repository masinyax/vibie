import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_note.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  final List<int> _selectedIndexes = [];

  final List<Map<String, String>> moods = [
    {'img': 'assets/images/mood1.png', 'label': 'Happy'},
    {'img': 'assets/images/mood2.png', 'label': 'Calm'},
    {'img': 'assets/images/mood3.png', 'label': 'Excited'},
    {'img': 'assets/images/mood4.png', 'label': 'Tired'},
    {'img': 'assets/images/mood5.png', 'label': 'Sad'},
    {'img': 'assets/images/mood6.png', 'label': 'Angry'},
    {'img': 'assets/images/mood7.png', 'label': 'Sleepy'},
    {'img': 'assets/images/mood8.png', 'label': 'Confused'},
    {'img': 'assets/images/mood9.png', 'label': 'Disappointed'},
    {'img': 'assets/images/mood10.png', 'label': 'Crying'},
    {'img': 'assets/images/mood11.png', 'label': 'Not Pleased'},
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // พื้นหลังขาวนวล
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'How was your day?',
          style: GoogleFonts.itim(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // หาตรงปุ่ม "Done" ใน app_bar ของ mood_selection.dart
        actions: [
          if (_selectedIndexes.isNotEmpty)
            TextButton(
              // ใน mood_selection.dart ตรง onPressed ของปุ่ม Done
              onPressed: () {
                if (_selectedIndexes.isNotEmpty) {
                  // ดึง Path รูปออกมาเป็น List<String> ตรงๆ
                  final List<String> paths = _selectedIndexes
                      .map((i) => moods[i]['img']!)
                      .toList();
                  final String labels = _selectedIndexes
                      .map((i) => moods[i]['label']!)
                      .join(', ');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoodNoteScreen(
                        moodImagePaths: paths,
                        moodLabel: labels,
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFFB7B2),
                ),
              ),
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: moods.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndexes.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedIndexes.remove(index);
                } else {
                  _selectedIndexes.add(index);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  // ขอบสีฟ้าอ่อนเมื่อถูกเลือก
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.05),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    // --- แก้ไขตรงนี้: เอา Opacity ออกเพื่อให้สีรูปสดเสมอ ---
                    child: Image.asset(
                      moods[index]['img']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    moods[index]['label']!,
                    style: GoogleFonts.itim(
                      fontSize: 15,
                      // เปลี่ยนสีตัวอักษรเมื่อเลือกเพื่อให้ดูเด่น
                      color: isSelected ? Colors.blue[700] : Colors.black54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
