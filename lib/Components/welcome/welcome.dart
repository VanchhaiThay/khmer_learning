import 'package:flutter/material.dart';
import 'package:khmerlearning/Components/auth/login/login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<String> images = [
    "assets/images/img_welcome1.avif",
    "assets/images/img_welcome2.avif",
    "assets/images/img_welcome3.avif",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 580,
          height: 760,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              // ---------------- GREEN CURVE HEADER ----------------
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(200),
                    bottomRight: Radius.circular(200),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // ---------------- IMAGE SLIDER ----------------
              SizedBox(
                height: 250,
                width: 230,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ---------------- DOT INDICATOR ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.black
                          : Colors.black26,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // ---------------- TITLE ----------------
              const Text(
                "Welcome to class",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xff00a78e),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // ---------------- SUBTITLE ----------------
              const Text(
                "We can Improve and teach you",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- BUTTON ----------------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd7b167),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Get Start",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
