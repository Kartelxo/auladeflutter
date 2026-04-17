import 'package:flutter/material.dart';
import 'models/pessoas.dart';
import 'models/produtos.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Split Bill")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Nova Conta"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BillScreen()),
            );
          },
        ),
      ),
    );
  }
}