import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khmerlearning/Components/auth/login/login.dart';
import 'package:khmerlearning/Components/auth/signup/signup.dart';
import 'package:khmerlearning/Components/home/homescreen/home.dart';
import 'package:khmerlearning/Components/home/sub_nav/profile_screen.dart';
import 'package:khmerlearning/Components/welcome/welcome.dart'; // <- import WelcomeScreen
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          // Decide the initial screen
          home: FirebaseAuth.instance.currentUser != null
              ? const HomeScreen()       // User already logged in
              : const WelcomeScreen(),  // User not logged in
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignUpScreen(),
            '/home': (_) => const HomeScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
