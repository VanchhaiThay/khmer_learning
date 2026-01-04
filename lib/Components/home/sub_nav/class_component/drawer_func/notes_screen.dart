import 'package:flutter/material.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "📒 Notes Screen",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
