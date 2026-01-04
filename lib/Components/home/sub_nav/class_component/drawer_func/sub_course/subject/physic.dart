import 'package:flutter/material.dart';

class Physicview extends StatelessWidget {
  const Physicview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("physic Subject")),
      body: const Center(
        child: Text(
          "📚 physic Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
