import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileRow extends StatelessWidget {
  final String userId;
  final String userName;
  final bool isDark;
  final VoidCallback onTapProfile;

  const ProfileRow({required this.userId, required this.userName, required this.isDark, required this.onTapProfile, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTapProfile,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage("https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId"),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $userName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("UID: ${userId.substring(0, 8)}", style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: userId));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UID copied"), duration: Duration(seconds: 1)));
                  },
                  child: Icon(Icons.copy, size: 16, color: isDark ? Colors.white70 : Colors.black45),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.notifications_none, size: 28, color: isDark ? Colors.white70 : Colors.black54),
      ],
    );
  }
}
