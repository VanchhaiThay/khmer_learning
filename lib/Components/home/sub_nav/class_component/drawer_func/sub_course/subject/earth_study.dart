import 'package:flutter/material.dart';

class EarthStudyview extends StatelessWidget {
  const EarthStudyview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("earth Subject")),
      body: const Center(
        child: Text(
          "📚 earth Subject Screen",  
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
