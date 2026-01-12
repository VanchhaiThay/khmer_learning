import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:khmerlearning/Components/home/homescreen/chatbot/bot_hint.dart';
import 'package:khmerlearning/Components/home/homescreen/widget/bottom_nav_item.dart';
import 'package:khmerlearning/Components/home/homescreen/widget/news_card.dart';
import 'package:khmerlearning/Components/home/homescreen/widget/profile_row.dart';
import 'package:khmerlearning/Components/home/homescreen/widget/subject_card.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/class_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/biology.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/earth_study.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/english.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/history.dart' show Historyview;
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/khmer_sub/khmer.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/math_sub/math.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/physic.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/technology.dart';
import 'package:khmerlearning/Components/home/sub_nav/message/message_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/profile_screen.dart';

import 'chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showAllSubjects = false;
  bool showBotHint = true;

  final List<Map<String, dynamic>> subjects = [
    {"title": "Khmer", "color": const Color(0xffffc98b), "image": "assets/images/khmer.png", "page": KhmerView()},
    {"title": "English", "color": const Color(0xffe6f959), "image": "assets/images/english.png", "page": Englishview()},
    {"title": "Physic", "color": const Color.fromARGB(255, 112, 78, 148), "image": "assets/images/physic.png", "page": const Physicview()},
    {"title": "History", "color": const Color(0xff8fa481), "image": "assets/images/history.png", "page": const Historyview()},
    {"title": "Math", "color": const Color.fromARGB(255, 97, 97, 46), "image": "assets/images/math.png", "page": const Mathview()},
    {"title": "Bio", "color": const Color(0xfff7a41f), "image": "assets/images/biology.png", "page": const Biologyview()},
    {"title": "Science", "color": const Color(0xffa8d5ff), "image": "assets/images/science.png", "page": const EarthStudyview()},
    {"title": "Geography", "color": const Color(0xffffa8a8), "image": "assets/images/geography.png", "page": const EarthStudyview()},
    {"title": "Chemistry", "color": const Color(0xffd9a8ff), "image": "assets/images/chemistry.png", "page": const Historyview()},
    {"title": "Technology", "color": const Color(0xffe46abf), "image": "assets/images/technology.png", "page": const Technologyview()},
  ];

  final List<Widget> pages = [
    const SizedBox(),
    const ClassScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => showBotHint = false);
    });
  }

  void onTabTapped(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "N/A";
    final userName = user?.displayName ?? "Student";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xffe3f2fd),
      body: Stack(
        children: [
          selectedIndex == 0 ? _buildHomeBody(userId, userName, isDark) : pages[selectedIndex],
          BotHintBubble(isDark: isDark, show: showBotHint),
          // ChatBot Floating Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatBotScreen()));
              },
              backgroundColor: const Color.fromARGB(255, 82, 241, 255),
              child: ClipOval(
                child: Image.asset(
                  "assets/bot/chatboticon.png",
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildHomeBody(String userId, String userName, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ProfileRow(userId: userId, userName: userName, isDark: isDark, onTapProfile: () => selectedIndex = 3),
          const SizedBox(height: 25),
          Text("Welcome to Class", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          _buildSubjectsHeader(isDark),
          const SizedBox(height: 20),
          GridView.builder(
            itemCount: showAllSubjects ? subjects.length : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return SubjectCard(
                title: subject["title"],
                color: subject["color"],
                image: subject["image"],
                page: subject["page"],
                isDark: isDark,
              );
            },
          ),
          const SizedBox(height: 30),
          Text("School News & Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                NewsCard(title: "Science Fair 2026", description: "Join our annual science fair and showcase your projects!", isDark: false),
                NewsCard(title: "New Library Opening", description: "The school library is now open with new books and resources.", isDark: false),
                NewsCard(title: "Sports Day", description: "Participate in fun sports events and win prizes!", isDark: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Subjects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        GestureDetector(
          onTap: () => setState(() => showAllSubjects = !showAllSubjects),
          child: Row(
            children: [
              Text(showAllSubjects ? "see less" : "see more", style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
              Icon(showAllSubjects ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: isDark ? Colors.white70 : Colors.black54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.grey[900]!, Colors.grey[800]!] : [const Color(0xff0D47A1), const Color(0xff1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(icon: Icons.home, label: "Home", isActive: selectedIndex == 0, onTap: () => onTabTapped(0), isDark: isDark),
          BottomNavItem(icon: Icons.class_, label: "Class", isActive: selectedIndex == 1, onTap: () => onTabTapped(1), isDark: isDark),
          BottomNavItem(icon: Icons.message, label: "Message", isActive: selectedIndex == 2, onTap: () => onTabTapped(2), isDark: isDark),
          BottomNavItem(icon: Icons.person, label: "Profile", isActive: selectedIndex == 3, onTap: () => onTabTapped(3), isDark: isDark),
        ],
      ),
    );
  }
}
