import 'package:flutter/material.dart';
import '../models.dart';
import 'result_screen.dart';
import 'dart:math';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<Person> people = [];
  List<Item> items = [];

  String generateId() => Random().nextDouble().toString();

  void addPersonDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova Pessoa"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            child: const Text("Adicionar"),
            onPressed: () {
              setState(() {
                people.add(Person(id: generateId(), name: controller.text));
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void addItemDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController priceCtrl = TextEditingController();
    List<Person> selected = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text("Novo Artigo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome")),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Preço")),
                const SizedBox(height: 10),
                const Text("Quem consumiu?"),
                ...people.map((p) => CheckboxListTile(
                      title: Text(p.name),
                      value: selected.contains(p),
                      onChanged: (v) {
                        setModalState(() {
                          v! ? selected.add(p) : selected.remove(p);
                        });
                      },
                    ))
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Adicionar"),
              onPressed: () {
                setState(() {
                  items.add(Item(
                    id: generateId(),
                    name: nameCtrl.text,
                    price: double.parse(priceCtrl.text),
                    consumers: selected,
                  ));
                });
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  void goToResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(people: people, items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Dados")),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(heroTag: "p", onPressed: addPersonDialog, child: const Icon(Icons.person_add)),
          const SizedBox(height: 10),
          FloatingActionButton(heroTag: "i", onPressed: addItemDialog, child: const Icon(Icons.add)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Pessoas"),
          ...people.map((p) => Text(p.name)),
          const SizedBox(height: 20),
          const Text("Artigos"),
          ...items.map((i) => Text("${i.name} - ${i.price}€")),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: goToResult,
            child: const Text("Ver Resultado"),
          )
        ],
      ),
    );
  }
}