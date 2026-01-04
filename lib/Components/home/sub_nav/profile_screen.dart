import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:khmerlearning/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "N/A";
    final userName = user?.displayName ?? "Student";
    final email = user?.email ?? "Not set";

    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purpleAccent.shade100,
                        Colors.deepPurple.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId",
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "UID: ${userId.substring(0, 8)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 6),
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
                        color: brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Dark Mode Toggle Card
                _buildInfoCard(
                  context,
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeNotifier.value =
                          value ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeColor: Colors.deepPurpleAccent,
                  ),
                ),

                const SizedBox(height: 10),

                // Personal Info Cards
                _buildInfoCard(
                  context,
                  icon: Icons.person,
                  title: "Full Name",
                  subtitle: userName,
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.email,
                  title: "Email",
                  subtitle: email,
                ),
                _buildInfoCard(
                  context,
                  icon: Icons.key,
                  title: "UID",
                  subtitle: userId,
                  trailing: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: userId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("UID copied"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(Icons.copy, color: Color(0xff6c5ce7)),
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/login', (route) => false);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error logging out: $e")),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      Widget? trailing}) {
    final brightness = Theme.of(context).brightness;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor:
          brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade300,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xff6c5ce7), size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}
