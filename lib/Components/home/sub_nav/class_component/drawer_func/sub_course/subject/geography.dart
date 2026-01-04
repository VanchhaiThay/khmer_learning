import 'package:flutter/material.dart';

class Geographyview extends StatelessWidget {
  const Geographyview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("geo Subject")),
      body: const Center(
        child: Text(
          "📚 geo Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
