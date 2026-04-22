import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class MoodNoteScreen extends StatefulWidget {
  final List<String> moodImagePaths;
  final String moodLabel;

  const MoodNoteScreen({
    super.key,
    required this.moodImagePaths,
    required this.moodLabel,
  });

  @override
  State<MoodNoteScreen> createState() => _MoodNoteScreenState();
}

class _MoodNoteScreenState extends State<MoodNoteScreen> {
  TextAlign _currentTextAlign = TextAlign.left;
  
  String _selectedFont = 'Itim'; 
  double _fontSize = 20.0;

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];

  TextStyle _getDynamicTextStyle() {
    switch (_selectedFont) {
      case 'Kanit': return GoogleFonts.kanit(fontSize: _fontSize, color: Colors.black87);
      case 'Mali': return GoogleFonts.mali(fontSize: _fontSize, color: Colors.black87);
      case 'Chakra Petch': return GoogleFonts.chakraPetch(fontSize: _fontSize, color: Colors.black87);
      case 'Sriracha': return GoogleFonts.sriracha(fontSize: _fontSize, color: Colors.black87);
      default: return GoogleFonts.itim(fontSize: _fontSize, color: Colors.black87);
    }
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
                  Text('Text Settings', 
                    style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      const Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Divider(),
                  const SizedBox(height: 10),
                  Text('Font Style', style: GoogleFonts.itim(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _fontOption('Itim', GoogleFonts.itim(), setModalState),
                        _fontOption('Kanit', GoogleFonts.kanit(), setModalState),
                        _fontOption('Mali', GoogleFonts.mali(), setModalState),
                        _fontOption('Chakra Petch', GoogleFonts.chakraPetch(), setModalState),
                        _fontOption('Sriracha', GoogleFonts.sriracha(), setModalState),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Center(
          child: Text(name, style: style.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
          )),
        ),
      ),
    );
  }

  Future<void> _requestPhotoPermission() async {
    var status = await Permission.photos.status;
    if (status.isGranted || await Permission.photos.request().isGranted) {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('April 21, 2026', style: GoogleFonts.itim(fontSize: 18, color: Colors.black54)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black, size: 28),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('21', style: GoogleFonts.itim(fontSize: 40, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationThickness: 2)),
                    Text('Tuesday', style: GoogleFonts.itim(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // ก้อนอารมณ์
            Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
              children: widget.moodImagePaths.map((path) {
                return Image.asset(path, width: 70, height: 70, fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red, size: 40));
              }).toList(),
            ),

            if (_selectedImages != null && _selectedImages!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Wrap(
                  spacing: 8,
                  children: _selectedImages!.map((file) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(file.path), width: 100, height: 100, fit: BoxFit.cover),
                  )).toList(),
                ),
              ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(widget.moodLabel, style: GoogleFonts.itim(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            
            const SizedBox(height: 30),

            TextField(
              textAlign: _currentTextAlign,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: _getDynamicTextStyle(),
              decoration: const InputDecoration(
                hintText: 'วันนี้เป็นยังไงบ้าง... บอก Vibie หน่อยนะ',
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        decoration: const BoxDecoration(color: Color(0xFFF5F5F2)),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.image_outlined, color: Colors.black54), onPressed: _requestPhotoPermission),
            const SizedBox(width: 10),

            //ปุ่มตั้งค่าฟอนต์
            IconButton(icon: const Icon(Icons.text_fields, color: Colors.black54), onPressed: _showTextSettings),
            const SizedBox(width: 10),

            IconButton(
              icon: Icon(
                _currentTextAlign == TextAlign.left ? Icons.format_align_left :
                _currentTextAlign == TextAlign.center ? Icons.format_align_center : Icons.format_align_right,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  if (_currentTextAlign == TextAlign.left) _currentTextAlign = TextAlign.center;
                  else if (_currentTextAlign == TextAlign.center) _currentTextAlign = TextAlign.right;
                  else _currentTextAlign = TextAlign.left;
                });
              },
            ),

            const Spacer(),          ],
        ),
      ),
    );
  }
}