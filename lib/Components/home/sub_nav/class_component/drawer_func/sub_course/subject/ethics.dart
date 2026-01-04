import 'package:flutter/material.dart';

class Ethicsview extends StatelessWidget {
  const Ethicsview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ethic Subject")),
      body: const Center(
        child: Text(
          "📚 ethic Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
