import 'package:flutter/material.dart';

class Mathview extends StatelessWidget {
  const Mathview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("math Subject")),
      body: const Center(
        child: Text(
          "📚 math Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
