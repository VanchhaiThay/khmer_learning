import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khmerlearning/Components/survey/survey.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _pageController;
  late Timer _timer;

  int currentIndex = 0;

  final List<String> images = [
    "assets/images/welcome1.png",
    "assets/images/welcome2.png",
    "assets/images/welcome3.png",
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.7);

    // ✅ AUTO SCROLL
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) return;

      if (currentIndex < images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double height = 250;
    const double width = 230;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 580,
          height: 760,
          color: Colors.white,
          child: Column(
            children: [
              // HEADER
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // AUTO SCROLL IMAGES
              SizedBox(
                height: height,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_pageController.position.haveDimensions) {
                          scale =
                              (_pageController.page! - index).abs();
                          scale = (1 - scale * 0.25).clamp(0.8, 1.0);
                        }

                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                images[index],
                                height: height,
                                width: width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // DOT INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: currentIndex == index ? 14 : 10,
                    height: currentIndex == index ? 14 : 10,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.green
                          : Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome to class",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xff00a78e),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "We can Improve and teach you",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // NEXT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd7b167),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SurveyScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Next",
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
