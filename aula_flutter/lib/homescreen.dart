import 'package:flutter/material.dart';
import 'models/pessoas.dart';
import 'models/produtos.dart';
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

  void addPerson() {
    if (nameController.text.isEmpty) return;
    setState(() {
      people.add(Person(id: DateTime.now().toString(), name: nameController.text));
      nameController.clear();
    });
  }

  void addItem() {
    if (itemController.text.isEmpty) return;
    setState(() {
      items.add(Item(
        name: itemController.text,
        price: double.parse(priceController.text),
        quantity: int.parse(qtyController.text),
      ));
      itemController.clear();
      priceController.clear();
      qtyController.clear();
    });
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
      appBar: AppBar(title: const Text('Conta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text("Adicionar Pessoa"),
          TextField(controller: nameController),
          ElevatedButton(onPressed: addPerson, child: const Text("Adicionar")),

          const Divider(),

          const Text("Adicionar Produto"),
          TextField(controller: itemController, decoration: const InputDecoration(labelText: "Nome")),
          TextField(controller: priceController, decoration: const InputDecoration(labelText: "Preço"), keyboardType: TextInputType.number),
          TextField(controller: qtyController, decoration: const InputDecoration(labelText: "Quantidade"), keyboardType: TextInputType.number),
          ElevatedButton(onPressed: addItem, child: const Text("Adicionar Produto")),

          const SizedBox(height: 20),
          ElevatedButton(onPressed: goAssign, child: const Text("Atribuir Produtos")),
        ],
      ),
    );
  }
}