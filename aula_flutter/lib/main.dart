import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const MyApp());
}

class My app extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData(primarySwatch: Colors.green)
      home: HomePage(),
    );
  }
}