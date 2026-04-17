import 'package:flutter/material.dart';
import '../models/pessoas.dart';
import '../models/produtos.dart';
import 'assignscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Person> people = [];
  List<Item> items = [];

  final nameController = TextEditingController();
  final itemController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();

  /// 👤 ADD PESSOA + TOAST
 void addPerson() {
  if (nameController.text.isEmpty) return;

  setState(() {
    people.add(
      Person(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
      ),
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Pessoa adicionada: ${nameController.text}"),
      duration: const Duration(seconds: 2),
    ),
  );

  nameController.clear();
}

  /// 🧾 ADD PRODUTO + TOAST
  void addItem() {
    if (itemController.text.isEmpty) return;

    setState(() {
      items.add(Item(
        name: itemController.text,
        price: double.parse(priceController.text),
        quantity: int.parse(qtyController.text),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Produto adicionado: ${itemController.text}"),
        duration: const Duration(seconds: 2),
      ),
    );

    itemController.clear();
    priceController.clear();
    qtyController.clear();
  }

  void goAssign() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignScreen(people: people, items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dividir Conta")),

      /// 🔥 BOTÃO FIXO EM BAIXO
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: goAssign,
          icon: const Icon(Icons.assignment),
          label: const Text("Atribuir Produtos"),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 👤 PESSOAS
          const Text("Adicionar Pessoa", style: TextStyle(fontSize: 18)),
          TextField(controller: nameController),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: addPerson,
            child: const Text("Adicionar Pessoa"),
          ),

          const Divider(),

          /// 🧾 PRODUTOS
          const Text("Adicionar Produto", style: TextStyle(fontSize: 18)),

          TextField(
            controller: itemController,
            decoration: const InputDecoration(labelText: "Nome"),
          ),

          TextField(
            controller: priceController,
            decoration: const InputDecoration(labelText: "Preço"),
            keyboardType: TextInputType.number,
          ),

          TextField(
            controller: qtyController,
            decoration: const InputDecoration(labelText: "Quantidade"),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 5),

          ElevatedButton(
            onPressed: addItem,
            child: const Text("Adicionar Produto"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}