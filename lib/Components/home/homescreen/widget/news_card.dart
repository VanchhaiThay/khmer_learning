import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isDark;

  const NewsCard({required this.title, required this.description, required this.isDark, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Text(description, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
      ]),
    );
  }
}
