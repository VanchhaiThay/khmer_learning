import 'package:flutter/material.dart';

class Technologyview extends StatelessWidget {
  const Technologyview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Technology Subject")),
      body: const Center(
        child: Text(
          "📚 technology Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
