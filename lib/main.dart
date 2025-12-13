import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khmerlearning/Components/auth/login/login.dart';
import 'package:khmerlearning/Components/auth/signup/signup.dart' show SignUpScreen;
import 'package:khmerlearning/Components/home/home.dart';
import 'package:khmerlearning/Components/home/sub_nav/profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Global theme notifier
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
          theme: ThemeData.light(), // Light theme for default
          darkTheme: ThemeData.dark(), // Dark theme for app
          themeMode: currentMode, // Use the notifier
          initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
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
