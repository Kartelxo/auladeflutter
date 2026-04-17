import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../state/providers.dart';
import 'result_screen.dart';

class AssignScreen extends ConsumerStatefulWidget {
  const AssignScreen({super.key});

  @override
  ConsumerState<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends ConsumerState<AssignScreen> {
  @override
  void initState() {
    super.initState();
    // initialize providers for current products & people
    final people = ref.read(peopleProvider);
    final products = ref.read(productsProvider);
    for (var p in products) {
      ref.read(selectedProvider.notifier).initProduct(p.name, people);
      ref.read(unitsProvider.notifier).initProduct(p.name, people);
      ref.read(divideEnabledProvider.notifier).setFlag(p.name, false);
      ref.read(useUnitsProvider.notifier).setFlag(p.name, false);
    }
  }

  void go() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  double getTotal(Product p) => p.price * p.quantity;

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider);
    final products = ref.watch(productsProvider);
    final selected = ref.watch(selectedProvider);
    final units = ref.watch(unitsProvider);
    final divideFlags = ref.watch(divideEnabledProvider);
    final useUnitsFlags = ref.watch(useUnitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Atribuir")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...products.map((p) {
            final productSelected = selected[p.name] ?? {};
            final productUnits = units[p.name] ?? {};
            final divideEnabled = divideFlags[p.name] ?? false;
            final useUnits = useUnitsFlags[p.name] ?? false;

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
                      value: divideEnabled,
                      onChanged: (v) {
                        ref.read(divideEnabledProvider.notifier).setFlag(p.name, v);
                        if (!v) {
                          // reset selections/units
                          ref.read(unitsProvider.notifier).resetProduct(p.name, people);
                          ref.read(selectedProvider.notifier).resetProduct(p.name, people);
                          ref.read(useUnitsProvider.notifier).setFlag(p.name, false);
                        }
                      },
                    ),

                    if (divideEnabled) ...[
                      // escolha do modo de atribuição (Seleção ou Unidades)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('Seleção'),
                              selected: !useUnits,
                              selectedColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                              onSelected: (s) => ref.read(useUnitsProvider.notifier).setFlag(p.name, false),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Unidades'),
                              selected: useUnits,
                              selectedColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                              onSelected: (s) => ref.read(useUnitsProvider.notifier).setFlag(p.name, true),
                            ),
                          ],
                        ),
                      ),

                      ...people.map((person) {
                        if (useUnits) {
                          // mostra selector de unidades (0..p.quantity)
                          final current = productUnits[person.id] ?? 0;
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
                                final sumOther = (productUnits.entries)
                                    .where((e) => e.key != person.id)
                                    .map((e) => e.value)
                                    .fold<int>(0, (a, b) => a + b);
                                if (sumOther + value > p.quantity) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Não é possível atribuir mais de ${p.quantity} unidades para este produto.')),
                                  );
                                  return;
                                }
                                ref.read(unitsProvider.notifier).setUnits(p.name, person.id, value);
                                // atualizar selected para compatibilidade: selecionado se unidades>0
                                ref.read(selectedProvider.notifier).setSelection(p.name, person.id, value > 0);
                              },
                            ),
                          );
                        }

                        return CheckboxListTile(
                          title: Text(person.name),
                          value: productSelected[person.id] ?? false,
                          onChanged: (v) {
                            final newVal = v ?? false;
                            ref.read(selectedProvider.notifier).setSelection(p.name, person.id, newVal);
                            // manter unidades coerentes
                            if (!newVal) {
                              ref.read(unitsProvider.notifier).setUnits(p.name, person.id, 0);
                            } else if ((productUnits[person.id] ?? 0) == 0) {
                              ref.read(unitsProvider.notifier).setUnits(p.name, person.id, 1);
                            }
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }),
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