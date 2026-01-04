import 'package:flutter/material.dart';

class Biologyview extends StatelessWidget {
  const Biologyview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("bio Subject")),
      body: const Center(
        child: Text(
          "📚 bio Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
