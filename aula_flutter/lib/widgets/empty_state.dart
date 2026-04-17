import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String text;

  const EmptyState(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text),
      ),
    );
  }
}