import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final Color color;
  final String image;
  final Widget? page;
  final bool isDark;

  const SubjectCard({required this.title, required this.color, required this.image, this.page, this.isDark = false, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.7) : color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 55),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }
}
