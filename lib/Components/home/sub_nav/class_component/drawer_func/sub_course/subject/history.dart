import 'package:flutter/material.dart';

class Historyview extends StatelessWidget {
  const Historyview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("history Subject")),
      body: const Center(
        child: Text(
          "📚 history Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
