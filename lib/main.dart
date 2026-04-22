import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'insights_screen.dart';
import 'login.dart';
import 'mood_selection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => const MainDashboard(),
      },
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  DateTime _focusedDate = DateTime.now();

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
    'December'
  ];

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Stream<Map<int, String>> _moodsForFocusedMonthStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(<int, String>{});
    }

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
      final byDay = <int, String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final moodPaths = (data['moodImagePaths'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList();
        final entryDate = data['entryDate'];
        if (moodPaths.isEmpty || entryDate is! Timestamp) {
          continue;
        }
        byDay[entryDate.toDate().day] = moodPaths.first;
      }
      return byDay;
    });
  }

  void _showYearPicker() {
    int currentYearBE = DateTime.now().year + 543;
    int startYearBE = currentYearBE - 100;
    List<int> years = List.generate(101, (index) => startYearBE + index);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: const Color(0xFFF5F5F2),
        child: Column(
          children: [
            Container(
              height: 55,
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.itim(color: Colors.black54, fontSize: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Select Year',
                        style: GoogleFonts.itim(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Done',
                      style: GoogleFonts.itim(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFFF5F5F2),
                itemExtent: 45,
                scrollController: FixedExtentScrollController(
                  initialItem: years.length - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _focusedDate = DateTime(years[index] - 543, _focusedDate.month);
                  });
                },
                children: years
                    .map(
                      (y) => Center(
                        child: Text(
                          '$y BE',
                          style:
                              GoogleFonts.itim(fontSize: 22, color: Colors.black),
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
      builder: (context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Select Month',
                style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(_focusedDate.year, index + 1);
                        });
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = _getDaysInMonth(_focusedDate.year, _focusedDate.month);
    String monthName = _months[_focusedDate.month - 1];
    int yearBE = _focusedDate.year + 543;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black87),
        title: Text('Vibie', style: GoogleFonts.itim(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.black87),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InsightsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showYearPicker,
            child: Text(
              '$yearBE BE',
              style: GoogleFonts.itim(
                fontSize: 16,
                color: Colors.grey.shade600,
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
                decorationColor: Colors.blue.withValues(alpha: 0.3),
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
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<Map<int, String>>(
              stream: _moodsForFocusedMonthStream(),
              builder: (context, snapshot) {
                final moodByDay = snapshot.data ?? <int, String>{};
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      final moodPath = moodByDay[day];
                      if (moodPath != null) {
                        return Column(
                          children: [
                            Expanded(child: Image.asset(moodPath)),
                            const SizedBox(height: 2),
                            Text(
                              '$day',
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: Text(
                          '$day',
                          style: GoogleFonts.itim(color: Colors.black87),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoodSelectionScreen()),
          ).then((value) => setState(() {}));
        },
        backgroundColor: const Color(0xFF3D3D4E),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
