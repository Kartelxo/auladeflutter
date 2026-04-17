import 'package:flutter/material.dart';
import '../models/pessoas.dart';
import '../models/produtos.dart';
import 'billscreen.dart';

class AssignScreen extends StatefulWidget {
  final List<Person> people;
  final List<Item> items;

  const AssignScreen({super.key, required this.people, required this.items});

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {

  int totalUnitsSelected(Item item) {
    return item.consumption.values.fold(0, (a, b) => a + b);
  }

  void goToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillScreen(people: widget.people, items: widget.items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    for (var item in widget.items) {
      list.add(
        Card(
          child: ExpansionTile(
            title: Text(item.name),
            subtitle: Text("Qtd total: ${item.quantity} | ${item.price}€"),

            children: [

              /// CHOICE MODE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Por unidade"),
                    selected: item.splitMode == SplitMode.perUnit,
                    onSelected: (_) => setState(() => item.splitMode = SplitMode.perUnit),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Dividir conta"),
                    selected: item.splitMode == SplitMode.equal,
                    onSelected: (_) => setState(() => item.splitMode = SplitMode.equal),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔵 MODO POR UNIDADE (contador)
              if (item.splitMode == SplitMode.perUnit)
                ...widget.people.map((person) {
                  item.consumption.putIfAbsent(person, () => 0);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(person.name),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (item.consumption[person]! > 0) {
                                  item.consumption[person] =
                                      item.consumption[person]! - 1;
                                }
                              });
                            },
                          ),

                          Text(item.consumption[person].toString()),

                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (totalUnitsSelected(item) >= item.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Quantidade máxima atingida")),
                                );
                                return;
                              }

                              setState(() {
                                item.consumption[person] =
                                    item.consumption[person]! + 1;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }),

              /// 🟢 MODO DIVIDIR CONTA (checkbox)
              if (item.splitMode == SplitMode.equal)
                ...widget.people.map((person) {
                  bool selected = item.sharedBy.contains(person);

                  return CheckboxListTile(
                    title: Text(person.name),
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          item.sharedBy.add(person);
                        } else {
                          item.sharedBy.remove(person);
                        }
                      });
                    },
                  );
                }),
            ],
          ),
        ),
      );
    }

    list.add(
      ElevatedButton(
        onPressed: goToResults,
        child: const Text("Calcular Conta"),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Atribuir Consumo")),
      body: ListView(padding: const EdgeInsets.all(16), children: list),
    );
  }
}