import 'package:flutter/material.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/khmer_sub/khmerpdfviewer.dart';

class KhmerView extends StatelessWidget {
  const KhmerView({super.key});

  final List<Map<String, String>> grades = const [
    {"pdf": "assets/pdfs/khmergrade1.pdf"},
    {"pdf": "assets/pdfs/khmergrade2.pdf"},
    {"pdf": "assets/pdfs/khmergrade3.pdf"},
    {"pdf": "assets/pdfs/khmergrade4.pdf"},
    {"pdf": "assets/pdfs/khmergrade5.pdf"},
    {"pdf": "assets/pdfs/khmergrade6.pdf"},
    {"pdf": "assets/pdfs/khmergrade7.pdf"},
    {"pdf": "assets/pdfs/khmergrade8.pdf"},
    {"pdf": "assets/pdfs/khmergrade9.pdf"},
    {"pdf": "assets/pdfs/khmergrade10.pdf"},
    {"pdf": "assets/pdfs/khmergrade11.pdf"},
    {"pdf": "assets/pdfs/khmergrade12.pdf"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : const Color(0xfff0f2f7);
    final cardTextColor = isDark ? Colors.white : Colors.white;
    final gradientStart = isDark ? Colors.deepPurple.shade700 : const Color(0xFF3173FF);
    final gradientEnd = isDark ? Colors.deepPurple.shade400 : const Color(0xFFD8DFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Khmer Language",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.deepPurple.shade900 : const Color.fromARGB(255, 58, 100, 183),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KhmerPdfViewer(
                    title: "Khmer Language Grade ${index + 1}",
                    pdfPath: grades[index]["pdf"]!,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Khmer Language Grade ${index + 1}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: cardTextColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}