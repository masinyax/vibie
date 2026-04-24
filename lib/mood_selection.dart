import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_note.dart';

class MoodSelectionScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const MoodSelectionScreen({super.key, this.selectedDate});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  final List<int> _selectedIndexes = [];

  final List<Map<String, String>> moods = [
    {'img': 'assets/images/mood1.png', 'label': 'Crying'},
    {'img': 'assets/images/mood2.png', 'label': 'Happy'},
    {'img': 'assets/images/mood3.png', 'label': 'Super Angry'},
    {'img': 'assets/images/mood4.png', 'label': 'Tired'},
    {'img': 'assets/images/mood5.png', 'label': 'Not Pleased'},
    {'img': 'assets/images/mood6.png', 'label': 'Excited'},
    {'img': 'assets/images/mood7.png', 'label': 'Sad'},
    {'img': 'assets/images/mood8.png', 'label': 'Calm'},
    {'img': 'assets/images/mood9.png', 'label': 'Sleepy'},
    {'img': 'assets/images/mood10.png', 'label': 'Disappointed'},
    {'img': 'assets/images/mood11.png', 'label': 'Confused'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
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
        actions: [
          if (_selectedIndexes.isNotEmpty)
            TextButton(
              onPressed: () {
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
                      selectedDate: widget.selectedDate,
                    ),
                  ),
                );
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
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
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(255, 208, 226, 254)
                      : Colors.black.withOpacity(0.05),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset(
                          moods[index]['img']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    moods[index]['label']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.itim(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF3D3D4E)
                          : Colors.black54,
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
