import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:vibie/profile_screen.dart';
import 'insights_screen.dart';
import 'login.dart';
import 'mood_selection.dart';
import 'mood_note.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const VibieApp());
}

class VibieApp extends StatelessWidget {
  const VibieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibie Mood',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.itimTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainDashboard(),
      },
    );
  }
}

class GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const double gap = 30.0;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  DateTime _focusedDate = DateTime.now();

  int _getFirstDayOffset(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  Future<void> _fetchNotesAndShow(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFB7B2)),
      ),
    );

    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .where(
            'entryDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('entryDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      Navigator.pop(context);

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodNoteScreen(
              docId: doc.id,
              moodImagePaths: List<String>.from(data['moodImagePaths'] ?? []),
              moodLabel: data['moodLabel'] ?? "",
              existingNote: data['note'],
              existingFont: data['font'],
              existingFontSize: data['fontSize']?.toDouble(),
              existingTextAlign: data['textAlign'],
              selectedDate: date,
            ),
          ),
        ).then((value) => setState(() {}));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodSelectionScreen(selectedDate: date),
          ),
        ).then((value) => setState(() {}));
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error: $e");
    }
  }

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Stream<Map<int, List<String>>> _moodsForFocusedMonthStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(<int, List<String>>{});

    final start = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final end = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .where('entryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('entryDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          final byDay = <int, List<String>>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final moodPaths = (data['moodImagePaths'] as List<dynamic>? ?? [])
                .whereType<String>()
                .toList();
            final entryDate = data['entryDate'];
            if (moodPaths.isEmpty || entryDate is! Timestamp) continue;
            byDay[entryDate.toDate().day] = moodPaths;
          }
          return byDay;
        });
  }

  void _showYearPicker() {
    int currentYearAD = DateTime.now().year;
    List<int> years = List.generate(
      101,
      (index) => (currentYearAD - 50) + index,
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: const Color(0xFFF5F5F2),
        child: Column(
          children: [
            _buildPickerHeader('Select Year'),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFFF5F5F2),
                itemExtent: 45,
                scrollController: FixedExtentScrollController(initialItem: 50),
                onSelectedItemChanged: (index) {
                  setState(
                    () => _focusedDate = DateTime(
                      years[index],
                      _focusedDate.month,
                    ),
                  );
                },
                children: years
                    .map(
                      (y) => Center(
                        child: Text(
                          '$y',
                          style: GoogleFonts.itim(fontSize: 22),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Select Month',
              style: GoogleFonts.itim(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) => TextButton(
                  onPressed: () {
                    setState(
                      () =>
                          _focusedDate = DateTime(_focusedDate.year, index + 1),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    _months[index],
                    style: GoogleFonts.itim(
                      color: _focusedDate.month == index + 1
                          ? Colors.blue
                          : Colors.black87,
                      fontWeight: _focusedDate.month == index + 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerHeader(String title) {
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          CupertinoButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.itim(color: Colors.black54),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.itim(
                  fontSize: 18,
                  color: Colors.black54,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          CupertinoButton(
            child: Text('Done', style: GoogleFonts.itim(color: Colors.black54)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = _getDaysInMonth(_focusedDate.year, _focusedDate.month);
    int firstDayOffset = _getFirstDayOffset(
      _focusedDate.year,
      _focusedDate.month,
    );
    String monthName = _months[_focusedDate.month - 1];
    int yearAD = _focusedDate.year;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F2),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPaperPainter())),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Vibie',
                            style: GoogleFonts.itim(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3D3D4E),
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color.fromARGB(255, 255, 103, 93),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InsightsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showYearPicker,
                  child: Text(
                    '$yearAD',
                    style: GoogleFonts.itim(
                      fontSize: 16,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Text(
                    monthName,
                    style: GoogleFonts.itim(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue.withOpacity(0.2),
                      decorationThickness: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                        .map(
                          (day) => Text(
                            day,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black38,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<Map<int, List<String>>>(
                    stream: _moodsForFocusedMonthStream(),
                    builder: (context, snapshot) {
                      final moodByDay = snapshot.data ?? <int, List<String>>{};
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 10,
                              ),
                          itemCount: daysInMonth + firstDayOffset,
                          itemBuilder: (context, index) {
                            if (index < firstDayOffset)
                              return const SizedBox.shrink();

                            int day = index - firstDayOffset + 1;
                            final moodPath = moodByDay[day] ?? [];

                            return GestureDetector(
                              onTap: () => _fetchNotesAndShow(
                                DateTime(
                                  _focusedDate.year,
                                  _focusedDate.month,
                                  day,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: moodPath.isNotEmpty
                                        ? Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 1,
                                            runSpacing: 1,
                                            children: moodPath.map(
                                                  (p) => Image.asset(
                                                    p,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                )
                                                .toList(),
                                          )
                                        : Container(),
                                  ),
                                  Text(
                                    '$day',
                                    style: GoogleFonts.itim(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoodSelectionScreen(),
            ),
          ).then((value) => setState(() {}));
        },
        backgroundColor: const Color(0xFF3D3D4E),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
