import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/product.dart';

class ResultScreen extends StatelessWidget {
  final List<Person> people;
  final List<Product> products;
  final Map<String, Map<String, bool>> selected;
  final Map<String, Map<String, int>>? units;
  final Map<String, bool>? splitEquallyByProduct;

  const ResultScreen({
    super.key,
    required this.people,
    required this.products,
    required this.selected,
    this.units,
    this.splitEquallyByProduct,
  });

  double getPersonTotal(Person person) {
    // Se para este produto foi selecionado dividir igualmente, divide este produto pelo número de pessoas

    double total = 0;

    for (var product in products) {
      final productTotal = product.price * product.quantity;

      // Se para este produto está marcado dividir igualmente, aplica divisão direta
      if (splitEquallyByProduct?[product.name] ?? false) {
        total += productTotal / (people.isEmpty ? 1 : people.length);
        continue;
      }

      // Se existem unidades atribuídas para este produto, usar essa distribuição
      final productUnits = units?[product.name];
      if (productUnits != null) {
        final totalUnits = productUnits.values.fold<int>(0, (a, b) => a + b);
        if (totalUnits > 0) {
          final personUnits = productUnits[person.id] ?? 0;
          total += productTotal * (personUnits / totalUnits);
          continue;
        }
      }

      // Caso contrário, usar seleção booleana (checkboxes)
      final selectedPeople = selected[product.name]!
          .entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      if (selectedPeople.isEmpty) continue;

      if (selectedPeople.contains(person.id)) {
        total += productTotal / selectedPeople.length;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final overallTotal = products.fold<double>(0, (sum, prod) => sum + prod.price * prod.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Conta final summary card
          Card(
            color: Theme.of(context).colorScheme.primary.withAlpha((0.06 * 255).round()),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conta final', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${products.length} produtos', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text('€${overallTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Individual totals per person
          ...people.map((p) {
            final total = getPersonTotal(p);
            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()),
                  child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?'),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Total: €${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: products.map((product) {
                        final productTotal = product.price * product.quantity;
                        // compute share for this person for this product
                        double share = 0;
                        final prodUnits = units?[product.name];
                        if (prodUnits != null) {
                          final totalUnits = prodUnits.values.fold<int>(0, (a, b) => a + b);
                          if (totalUnits > 0) {
                            share = productTotal * ((prodUnits[p.id] ?? 0) / totalUnits);
                          }
                        }

                        final selectedPeople = selected[product.name]!.entries.where((e) => e.value).map((e) => e.key).toList();
                        if (selectedPeople.isNotEmpty && share == 0) {
                          if (selectedPeople.contains(p.id)) share = productTotal / selectedPeople.length;
                        }

                        if (share <= 0) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(product.name)),
                              Text('€${share.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}