import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/class_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/biology.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/earth_study.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/english.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/history.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/khmer_sub/khmer.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/math_sub/math.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/physic.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/subject/technology.dart';
import 'package:khmerlearning/Components/home/sub_nav/message/message_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showAllSubjects = false;

  // Subjects list with their target pages
  final List<Map<String, dynamic>> subjects = [
    {
      "title": "Khmer",
      "color": const Color(0xffffc98b),
      "image": "assets/images/khmer.png",
      "page": KhmerView(),
    },
    {
      "title": "English",
      "color": const Color(0xffe6f959),
      "image": "assets/images/english.png",
      "page": Englishview(),
    },
    {
      "title": "Physic",
      "color": const Color.fromARGB(255, 112, 78, 148),
      "image": "assets/images/physic.png",
      "page": const Physicview(),
    },
    {
      "title": "History",
      "color": const Color(0xff8fa481),
      "image": "assets/images/history.png",
      "page": const Historyview(),
    },
    {
      "title": "Math",
      "color": const Color.fromARGB(255, 97, 97, 46),
      "image": "assets/images/math.png",
      "page": const Mathview(),
    },
    {
      "title": "Bio",
      "color": const Color(0xfff7a41f),
      "image": "assets/images/biology.png",
      "page": const Biologyview(),
    },
    {
      "title": "Science",
      "color": const Color(0xffa8d5ff),
      "image": "assets/images/science.png",
      "page": const EarthStudyview(),
    },
    {
      "title": "Geography",
      "color": const Color(0xffffa8a8),
      "image": "assets/images/geography.png",
      "page": const EarthStudyview(),
    },
    {
      "title": "Chemistry",
      "color": const Color(0xffd9a8ff),
      "image": "assets/images/chemistry.png",
      "page": const Historyview(),
    },
    {
      "title": "Technology",
      "color": const Color(0xffe46abf),
      "image": "assets/images/technology.png",
      "page": const Technologyview(),
    },
  ];

  final List<Widget> pages = [
    const SizedBox(), // Home body
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
    final userId = user?.uid ?? "N/A";
    final userName = user?.displayName ?? "Student";

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xffe3f2fd),
      body: selectedIndex == 0
          ? _buildHomeBody(userId, userName, isDark)
          : pages[selectedIndex],
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [const Color(0xff0D47A1), const Color(0xff1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home,
            label: "Home",
            isActive: selectedIndex == 0,
            onTap: () => onTabTapped(0),
            isDark: isDark,
          ),
          _BottomNavItem(
            icon: Icons.class_,
            label: "Class",
            isActive: selectedIndex == 1,
            onTap: () => onTabTapped(1),
            isDark: isDark,
          ),
          _BottomNavItem(
            icon: Icons.message,
            label: "Message",
            isActive: selectedIndex == 2,
            onTap: () => onTabTapped(2),
            isDark: isDark,
          ),
          _BottomNavItem(
            icon: Icons.person,
            label: "Profile",
            isActive: selectedIndex == 3,
            onTap: () => onTabTapped(3),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(String userId, String userName, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Top Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.deepPurple, Colors.black87]
                    : [const Color(0xff8e2de2), const Color(0xff4a00e0)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                        "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId"),
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
                      children: [
                        Text(
                          "UID: ${userId.substring(0, 8)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
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
                          child: const Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: isDark ? Colors.white70 : Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          Text(
            "Welcome to Class",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 20),

          // Subjects header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subjects",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black),
              ),
              GestureDetector(
                onTap: () => setState(() => showAllSubjects = !showAllSubjects),
                child: Row(
                  children: [
                    Text(
                      showAllSubjects ? "see less" : "see more",
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    Icon(
                      showAllSubjects
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subject Grid
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
              return _SubjectCard(
                title: subject["title"],
                color: subject["color"],
                image: subject["image"],
                page: subject["page"],
                isDark: isDark,
              );
            },
          ),

          const SizedBox(height: 30),
          // NEWS / EVENTS SECTION
          Text(
            "School News & Events",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _NewsCard(
                  title: "Science Fair 2026",
                  description:
                      "Join our annual science fair and showcase your projects!",
                  isDark: isDark,
                ),
                _NewsCard(
                  title: "New Library Opening",
                  description:
                      "The school library is now open with new books and resources.",
                  isDark: isDark,
                ),
                _NewsCard(
                  title: "Sports Day",
                  description: "Participate in fun sports events and win prizes!",
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- SUBJECT CARD ----------------
class _SubjectCard extends StatelessWidget {
  final String title;
  final Color color;
  final String image;
  final Widget? page;
  final bool isDark;

  const _SubjectCard(
      {required this.title,
      required this.color,
      required this.image,
      this.page,
      this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Page not available yet")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.7) : color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 55),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- NEWS CARD ----------------
class _NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isDark;

  const _NewsCard(
      {required this.title, required this.description, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }
}

// ---------------- BOTTOM NAV ITEM ----------------
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isDark;

  const _BottomNavItem(
      {required this.icon,
      required this.label,
      this.isActive = false,
      this.onTap,
      this.isDark = false});

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
              color: isActive
                  ? (isDark ? Colors.grey[300] : Colors.white)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                size: 26, color: isActive ? Colors.blue : Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.blue : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
