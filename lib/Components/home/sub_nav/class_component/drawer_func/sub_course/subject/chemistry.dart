import 'package:flutter/material.dart';

class Chemistryview extends StatelessWidget {
  const Chemistryview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("chem Subject")),
      body: const Center(
        child: Text(
          "📚 chem Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
