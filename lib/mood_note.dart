import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MoodNoteScreen extends StatefulWidget {
  final List<String> moodImagePaths;
  final String moodLabel;
  final String? docId;
  final String? existingNote;
  final String? existingFont;
  final double? existingFontSize;
  final String? existingTextAlign;
  final DateTime? selectedDate;

  const MoodNoteScreen({
    super.key,
    required this.moodImagePaths,
    required this.moodLabel,
    this.docId,
    this.existingNote,
    this.existingFont,
    this.existingFontSize,
    this.existingTextAlign,
    this.selectedDate,
  });

  @override
  State<MoodNoteScreen> createState() => _MoodNoteScreenState();
}

class _MoodNoteScreenState extends State<MoodNoteScreen> {
  TextAlign _currentTextAlign = TextAlign.left;
  String _selectedFont = 'Itim';
  double _fontSize = 20.0;
  bool _isSaving = false;

  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  late List<String> _currentPaths;
  late String _currentLabel;

  final List<Map<String, String>> _allMoods = [
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
  void initState() {
    super.initState();
    _currentPaths = List<String>.from(widget.moodImagePaths);
    _currentLabel = widget.moodLabel;

    if (widget.existingNote != null)
      _noteController.text = widget.existingNote!;
    if (widget.existingFont != null) _selectedFont = widget.existingFont!;
    if (widget.existingFontSize != null) _fontSize = widget.existingFontSize!;
    if (widget.existingTextAlign != null) {
      _currentTextAlign = TextAlign.values.firstWhere(
        (e) => e.name == widget.existingTextAlign,
        orElse: () => TextAlign.left,
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  TextStyle _getDynamicTextStyle() {
    switch (_selectedFont) {
      case 'Kanit':
        return GoogleFonts.kanit(fontSize: _fontSize, color: Colors.black87);
      case 'Mali':
        return GoogleFonts.mali(fontSize: _fontSize, color: Colors.black87);
      case 'Chakra Petch':
        return GoogleFonts.chakraPetch(
          fontSize: _fontSize,
          color: Colors.black87,
        );
      case 'Sriracha':
        return GoogleFonts.sriracha(fontSize: _fontSize, color: Colors.black87);
      default:
        return GoogleFonts.itim(fontSize: _fontSize, color: Colors.black87);
    }
  }

  Future<void> _requestPhotoPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      final images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() => _selectedImages = images);
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      _showMessage('Vibie เข้าถึงรูปภาพไม่ได้ค่ะ');
    }
  }

  Future<void> _saveMoodEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final moodCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moods');
      final DateTime saveDate = widget.selectedDate ?? DateTime.now();

      final DateTime midnightDate = DateTime(
        saveDate.year,
        saveDate.month,
        saveDate.day,
      );
      final String dateStr =
          "${midnightDate.year}-${midnightDate.month.toString().padLeft(2, '0')}-${midnightDate.day.toString().padLeft(2, '0')}";

      final Map<String, dynamic> data = {
        'note': _noteController.text.trim(),
        'font': _selectedFont.toString(),
        'fontSize': _fontSize,
        'textAlign': _currentTextAlign.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'moodLabel': _currentLabel.toString(),
        'moodImagePaths': _currentPaths.map((e) => e.toString()).toList(),
        'entryDate': Timestamp.fromDate(midnightDate),
        'date': dateStr,
      };

      List<String> photoUrls = [];
      data['photoUrls'] = photoUrls;

      if (widget.docId != null) {
        await moodCollection.doc(widget.docId).update(data);
      } else {
        data.addAll({'createdAt': FieldValue.serverTimestamp()});
        await moodCollection.doc().set(data);
      }

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      _showMessage('Vibie saved your memory');
    } catch (e) {
      print("Save Error: $e");
      _showMessage('Something went wrong!');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message, style: GoogleFonts.itim())));
  }

  void _showTextSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              height: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Settings',
                    style: GoogleFonts.itim(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 14.0,
                          max: 40.0,
                          activeColor: const Color(0xFFFFB7B2),
                          onChanged: (value) {
                            setModalState(() => _fontSize = value);
                            setState(() => _fontSize = value);
                          },
                        ),
                      ),
                      const Text(
                        'A',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Font Style',
                    style: GoogleFonts.itim(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _fontOption('Itim', GoogleFonts.itim(), setModalState),
                        _fontOption(
                          'Kanit',
                          GoogleFonts.kanit(),
                          setModalState,
                        ),
                        _fontOption('Mali', GoogleFonts.mali(), setModalState),
                        _fontOption(
                          'Chakra Petch',
                          GoogleFonts.chakraPetch(),
                          setModalState,
                        ),
                        _fontOption(
                          'Sriracha',
                          GoogleFonts.sriracha(),
                          setModalState,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _fontOption(String name, TextStyle style, StateSetter setModalState) {
    bool isSelected = _selectedFont == name;
    return GestureDetector(
      onTap: () {
        setModalState(() => _selectedFont = name);
        setState(() => _selectedFont = name);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 20, top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: style.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = widget.selectedDate ?? DateTime.now();
    final List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.docId != null ? 'Edit Memory' : 'New Memory',
          style: GoogleFonts.itim(color: Colors.black54),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFFFB7B2), size: 32),
            onPressed: _isSaving ? null : _saveMoodEntry,
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${displayDate.day}',
                              style: GoogleFonts.itim(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(
                                  0xFFFFB7B2,
                                ).withOpacity(0.5),
                                decorationThickness: 4,
                              ),
                            ),
                            Text(
                              weekDays[displayDate.weekday - 1],
                              style: GoogleFonts.itim(
                                fontSize: 18,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(_currentPaths.length, (index) {
                    final path = _currentPaths[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          int allMoodsIndex = _allMoods.indexWhere(
                            (m) => m['img'] == path,
                          );
                          int nextIndex =
                              (allMoodsIndex + 1) % _allMoods.length;

                          _currentPaths[index] = _allMoods[nextIndex]['img']!;

                          if (_currentPaths.length == 1) {
                            _currentLabel = _allMoods[nextIndex]['label']!;
                          } else {
                            _currentLabel = "Mixed Moods";
                          }
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          path,
                          key: ValueKey(path),
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB7B2).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentLabel,
                    style: GoogleFonts.itim(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3D3D4E),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _noteController,
                  textAlign: _currentTextAlign,
                  maxLines: null,
                  style: _getDynamicTextStyle(),
                  decoration: const InputDecoration(
                    hintText: 'บอก Vibie หน่อยนะ...',
                    border: InputBorder.none,
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isSaving)
            const ColoredBox(
              color: Colors.black12,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB7B2)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          bottom: 35,
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: Colors.black54),
              onPressed: _isSaving ? null : _requestPhotoPermission,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.black54),
              onPressed: _isSaving ? null : _showTextSettings,
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                _currentTextAlign == TextAlign.left
                    ? Icons.format_align_left
                    : _currentTextAlign == TextAlign.center
                    ? Icons.format_align_center
                    : Icons.format_align_right,
                color: Colors.black87,
              ),
              onPressed: () => setState(() {
                if (_currentTextAlign == TextAlign.left)
                  _currentTextAlign = TextAlign.center;
                else if (_currentTextAlign == TextAlign.center)
                  _currentTextAlign = TextAlign.right;
                else
                  _currentTextAlign = TextAlign.left;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
