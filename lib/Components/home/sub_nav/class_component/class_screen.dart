import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/activity.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/assignments_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/sub_course/courses_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/notes_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/other_screen.dart';
import 'package:khmerlearning/Components/home/sub_nav/class_component/drawer_func/schedule_screen.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  int selectedIndex = 0;

  void changeScreen(int index) {
    setState(() => selectedIndex = index);
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    final userName = currentUser.displayName ?? "Student";
    final userEmail = currentUser.email ?? "No email";
    final userId = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: const Color(0xff1f5bff),
        centerTitle: true,
        title: const Text(
          "Classes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xff6c5ce7)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(userEmail,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Courses"),
              onTap: () => changeScreen(0),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text("Activities"),
              onTap: () => changeScreen(1),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Assignments"),
              onTap: () => changeScreen(2),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text("Notes"),
              onTap: () => changeScreen(3),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text("Schedule"),
              onTap: () => changeScreen(4),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Other"),
              onTap: () => changeScreen(5),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              },
            ),
          ],
        ),
      ),
      // ================= BODY =================
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          CoursesView(),
          Activityview(),
          AssignmentsView(),
          NotesView(),
          ScheduleView(),
          OtherView(),
        ],
      ),
    );
  }
}
