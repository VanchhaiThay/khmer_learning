import 'package:flutter/material.dart';

class BotHintBubble extends StatelessWidget {
  final bool isDark;
  final bool show;

  const BotHintBubble({required this.isDark, required this.show, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: show ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 5))],
          ),
          child: Text(
            "Hi! How can I help you?",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
