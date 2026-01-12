import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isDark;

  const BottomNavItem({required this.icon, required this.label, this.isActive = false, this.onTap, this.isDark = false, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? (isDark ? Colors.grey[300] : Colors.white) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 26, color: isActive ? Colors.blue : Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.blue : Colors.white)),
        ],
      ),
    );
  }
}
