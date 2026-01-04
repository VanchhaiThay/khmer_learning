import 'package:flutter/material.dart';

class Englishview extends StatelessWidget {
  const Englishview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("english Subject")),
      body: const Center(
        child: Text(
          "📚 english Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
