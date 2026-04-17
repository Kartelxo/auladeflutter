import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/product.dart';
import 'result_screen.dart';

class AssignScreen extends StatefulWidget {
  final List<Person> people;
  final List<Product> products;

  const AssignScreen({
    super.key,
    required this.people,
    required this.products,
  });

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {
  Map<String, Map<String, bool>> selected = {};
  // unidades atribuídas por produto -> pessoaId -> unidades
  Map<String, Map<String, int>> units = {};

  // controlo por produto: se a divisão está ativada e se o modo é por unidades
  final Map<String, bool> divideEnabled = {};
  final Map<String, bool> useUnits = {};

  @override
  void initState() {
    super.initState();

    for (var p in widget.products) {
      selected[p.name] = {};
      units[p.name] = {};
  divideEnabled[p.name] = false;
  useUnits[p.name] = false;
      for (var person in widget.people) {
        selected[p.name]![person.id] = false;
        units[p.name]![person.id] = 0;
      }
    }
  }

  void go() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          people: widget.people,
          products: widget.products,
          selected: selected,
          units: units,
        ),
      ),
    );
  }

  double getTotal(Product p) =>
      p.price * p.quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atribuir")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.products.map((p) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            backgroundColor: Colors.blue.shade50,
                            label: Text('Qtd: ${p.quantity}'),
                          ),
                          Chip(
                            backgroundColor: Colors.green.shade50,
                            label: Text('€${p.price.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Total: €${getTotal(p).toStringAsFixed(2)}'),
                  ),

                children: [
                  // switch para ativar/desativar a funcionalidade de divisão para este produto
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ativar divisão para este produto'),
                    value: divideEnabled[p.name] ?? false,
                    onChanged: (v) {
                      setState(() {
                        divideEnabled[p.name] = v;
                        if (!v) {
                          // reset selections/units
                          units[p.name] = {for (var person in widget.people) person.id: 0};
                          selected[p.name] = {for (var person in widget.people) person.id: false};
                          useUnits[p.name] = false;
                        }
                      });
                    },
                  ),

                  if (divideEnabled[p.name] ?? false) ...[
                    // escolha do modo de atribuição (Seleção ou Unidades)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Seleção'),
                            selected: !(useUnits[p.name] ?? false),
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                            onSelected: (s) => setState(() => useUnits[p.name] = false),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Unidades'),
                            selected: useUnits[p.name] ?? false,
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                            onSelected: (s) => setState(() => useUnits[p.name] = true),
                          ),
                        ],
                      ),
                    ),

                    ...widget.people.map((person) {
                      if (useUnits[p.name] ?? false) {
                        // mostra selector de unidades (0..p.quantity)
                        final current = units[p.name]![person.id] ?? 0;
                        return ListTile(
                          title: Text(person.name),
                          trailing: DropdownButton<int>(
                            value: current,
                            items: List.generate(
                              p.quantity + 1,
                              (i) => DropdownMenuItem(value: i, child: Text('$i')),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              final sumOther = units[p.name]!.entries
                                  .where((e) => e.key != person.id)
                                  .map((e) => e.value)
                                  .fold<int>(0, (a, b) => a + b);
                              if (sumOther + value > p.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Não é possível atribuir mais de ${p.quantity} unidades para este produto.')),
                                );
                                return;
                              }
                              setState(() {
                                units[p.name]![person.id] = value;
                                // atualizar selected para compatibilidade: selecionado se unidades>0
                                selected[p.name]![person.id] = value > 0;
                              });
                            },
                          ),
                        );
                      }

                      return CheckboxListTile(
                        title: Text(person.name),
                        value: selected[p.name]![person.id],
                        onChanged: (v) {
                          setState(() {
                            selected[p.name]![person.id] = v!;
                            // manter unidades coerentes
                            if (!v) {
                              units[p.name]![person.id] = 0;
                            } else if (units[p.name]![person.id] == 0) {
                              units[p.name]![person.id] = 1;
                            }
                          });
                        },
                      );
                    }),
                  ],
                ],
              ),
            )
            );
          }
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: go,
          child: const Text("Ver resultado"),
        ),
      ),
    );
  }
}