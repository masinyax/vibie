import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // สำหรับ Year Picker แบบ iOS
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'mood_selection.dart';
import 'insights_screen.dart';

// ตัวแปรเก็บข้อมูลอารมณ์ (จำลอง Database)
Map<String, List<String>> savedMoods = {}; 

void main() {
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

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  DateTime _focusedDate = DateTime.now();

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // --- ฟังก์ชันเลือกปี (แบบวงล้อสีดำ มินิมอล) ---
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
                border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    child: Text('Cancel', style: GoogleFonts.itim(color: Colors.black54)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Select Year', 
                        style: GoogleFonts.itim(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Done', style: GoogleFonts.itim(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  initialItem: years.indexOf(_focusedDate.year + 543),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _focusedDate = DateTime(years[index] - 543, _focusedDate.month);
                  });
                },
                children: years.map((y) => Center(
                  child: Text('$y BE', style: GoogleFonts.itim(fontSize: 22, color: Colors.black)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ฟังก์ชันเลือกเดือน ---
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Select Month', style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(_focusedDate.year, index + 1);
                        });
                        Navigator.pop(context);
                      },
                      child: Text(_months[index],
                        style: GoogleFonts.itim(
                          color: _focusedDate.month == index + 1 ? Colors.blue : Colors.black87,
                          fontWeight: _focusedDate.month == index + 1 ? FontWeight.bold : FontWeight.normal,
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
      body: Stack(
        children: [
          // 1. แบคกราวด์รูป home.png (จางๆ แบบ Mooda)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, 
              child: Image.asset(
                'assets/images/home.png', 
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. เนื้อหา Dashboard
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // ชื่อแอปตัวใหญ่เด่นกลางหน้าจอ
                Text(
                  'Vibie',
                  style: GoogleFonts.itim(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3D3D4E),
                    letterSpacing: -1.0,
                  ),
                ),
                
                const SizedBox(height: 5),

                // เดือนและปี (กดเพื่อเปลี่ยน)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showMonthPicker,
                      child: Text(
                        '$monthName  ',
                        style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showYearPicker,
                      child: Text(
                        '$yearBE BE',
                        style: GoogleFonts.itim(fontSize: 16, color: Colors.black38, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // หัวตาราง SUN - SAT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                        .map((day) => Text(day, style: GoogleFonts.itim(fontSize: 10, color: Colors.black38)))
                        .toList(),
                  ),
                ),

                // ตารางปฏิทิน
                Expanded(
                  child: Padding(
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
                        String dateKey = "$yearBE-${_focusedDate.month}-$day";

                        if (savedMoods.containsKey(dateKey)) {
                          return Column(
                            children: [
                              Expanded(child: Image.asset(savedMoods[dateKey]![0])),
                              const SizedBox(height: 2),
                              Text('$day', style: const TextStyle(fontSize: 10, decoration: TextDecoration.underline)),
                            ],
                          );
                        }
                        return Center(
                          child: Text('$day', style: GoogleFonts.itim(color: Colors.black87)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ปุ่มเมนูและไอคอนกราฟ
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: const Icon(Icons.menu, color: Colors.black87),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.black87),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InsightsScreen())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodSelectionScreen()))
              .then((value) => setState(() {}));
        },
        backgroundColor: const Color(0xFF3D3D4E),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}