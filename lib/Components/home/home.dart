import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/message/message_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/profile_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/sub_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showAllSubjects = false;

  final List<Map<String, dynamic>> subjects = [
    {"title": "Khmer", "color": const Color(0xffffc98b), "image": "assets/images/khmer.png"},
    {"title": "English", "color": const Color.fromARGB(167, 230, 249, 89), "image": "assets/images/english.png"},
    {"title": "Physic", "color": const Color.fromARGB(176, 185, 255, 139), "image": "assets/images/physic.png"},
    {"title": "History", "color": const Color.fromARGB(255, 143, 164, 129), "image": "assets/images/history.png"},
    {"title": "Math", "color": const Color.fromARGB(191, 255, 255, 139), "image": "assets/images/math.png"},
    {"title": "Bio", "color": const Color.fromARGB(255, 247, 164, 31), "image": "assets/images/biology.png"},
    {"title": "Science", "color": const Color(0xffa8d5ff), "image": "assets/images/science.png"},
    {"title": "Geography", "color": const Color(0xffffa8a8), "image": "assets/images/geography.png"},
    {"title": "Chemistry", "color": const Color(0xffd9a8ff), "image": "assets/images/chemistry.png"},
    {"title": "Technology", "color": const Color.fromARGB(255, 228, 106, 191), "image": "assets/images/technology.png"},
  ];

  final List<Widget> pages = [
    const SubHomeScreen(),
    const ClassScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "N/A"; // <-- use full UID
    final userName = user?.displayName ?? "Student";

    return Scaffold(
      body: selectedIndex == 0 ? _buildHomeBody(userId, userName) : pages[selectedIndex],

      // ================= BOTTOM NAV BAR =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 76, 115, 183),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.book,
              label: "Home",
              isActive: selectedIndex == 0,
              onTap: () => onTabTapped(0),
            ),
            _BottomNavItem(
              icon: Icons.group,
              label: "Class",
              isActive: selectedIndex == 1,
              onTap: () => onTabTapped(1),
            ),
            _BottomNavItem(
              icon: Icons.message,
              label: "Message",
              isActive: selectedIndex == 2,
              onTap: () => onTabTapped(2),
            ),
            _BottomNavItem(
              icon: Icons.person,
              label: "Profile",
              isActive: selectedIndex == 3,
              onTap: () => onTabTapped(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody(String userId, String userName) {
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ================= TOP PROFILE CARD =================
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(202, 119, 0, 215),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId",
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello $userName",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "UID: ${userId.substring(0, 8)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("UID copied"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Welcome to class",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // ================= SUBJECT HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subjects",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllSubjects = !showAllSubjects; // toggle expand/collapse
                  });
                },
                child: Row(
                  children: [
                    Text(
                      showAllSubjects ? "see less" : "see more",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black54, // White in dark mode, black54 in light mode
                      ),
                    ),
                    Icon(
                      showAllSubjects ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ================= SUBJECT GRID =================
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: (showAllSubjects ? subjects : subjects.take(4).toList())
                .map((subject) => _SubjectCard(
                      title: subject["title"],
                      color: subject["color"],
                      image: subject["image"],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// SUBJECT CARD
//////////////////////////////////////////////////////////
class _SubjectCard extends StatelessWidget {
  final String title;
  final Color color;
  final String image;

  const _SubjectCard({
    required this.title,
    required this.color,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 55),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// BOTTOM NAV ITEM
//////////////////////////////////////////////////////////
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

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
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 26, color: Colors.black),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
