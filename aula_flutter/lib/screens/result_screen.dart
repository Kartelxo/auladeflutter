import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../models/product.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  double _personShareForProduct({
    required Map<String, Map<String, bool>> selected,
    required Map<String, Map<String, int>> units,
    required Map<String, bool> divideFlags,
    required Map<String, bool> useUnitsFlags,
    required List<String> peopleIds,
    required String personId,
    required Product product,
  }) {
    final productTotal = product.price * product.quantity;

    // if divide not enabled, skip
    if (!(divideFlags[product.name] ?? false)) return 0;

    // units mode
    if ((useUnitsFlags[product.name] ?? false)) {
      final prodUnits = units[product.name] ?? {};
      final totalUnits = prodUnits.values.fold<int>(0, (a, b) => a + b);
      if (totalUnits > 0) {
        final personUnits = prodUnits[personId] ?? 0;
        return productTotal * (personUnits / totalUnits);
      }
      return 0;
    }

    // selection mode
    final selectedPeople = (selected[product.name] ?? {}).entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedPeople.isEmpty) return 0;
    if (selectedPeople.contains(personId)) {
      return productTotal / selectedPeople.length;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider);
    final products = ref.watch(productsProvider);
    final selected = ref.watch(selectedProvider);
    final units = ref.watch(unitsProvider);
    final divideFlags = ref.watch(divideEnabledProvider);
    final useUnitsFlags = ref.watch(useUnitsProvider);
    final overallTotal = ref.watch(overallTotalProvider);

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
            final total = products.fold<double>(0, (sum, product) => sum + _personShareForProduct(
              selected: selected,
              units: units,
              divideFlags: divideFlags,
              useUnitsFlags: useUnitsFlags,
              peopleIds: people.map((e) => e.id).toList(),
              personId: p.id,
              product: product,
            ));

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
                        final share = _personShareForProduct(
                          selected: selected,
                          units: units,
                          divideFlags: divideFlags,
                          useUnitsFlags: useUnitsFlags,
                          peopleIds: people.map((e) => e.id).toList(),
                          personId: p.id,
                          product: product,
                        );

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
          }),
        ],
      ),
    );
  }
}