import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/product.dart';

class ProductAssignmentCard extends StatefulWidget {
  final Product product;
  final List<Person> people;
  final Map<String, Map<String, bool>> selected;
  final Map<String, Map<String, int>> quantityAssign;
  final VoidCallback onChanged;

  const ProductAssignmentCard({
    super.key,
    required this.product,
    required this.people,
    required this.selected,
    required this.quantityAssign,
    required this.onChanged,
  });

  @override
  State<ProductAssignmentCard> createState() =>
      _ProductAssignmentCardState();
}

class _ProductAssignmentCardState extends State<ProductAssignmentCard> {
  bool splitMode = true;

  void togglePerson(String id, bool v) {
    setState(() {
      widget.selected[widget.product.name]![id] = v;
    });
    widget.onChanged();
  }

  void addUnit(String id) {
    final current =
        widget.quantityAssign[widget.product.name]![id] ?? 0;

    final totalAssigned = widget.quantityAssign[widget.product.name]!
        .values
        .fold(0, (a, b) => a + b);

    if (totalAssigned >= widget.product.quantity) return;

    setState(() {
      widget.quantityAssign[widget.product.name]![id] =
          current + 1;
    });

    widget.onChanged();
  }

  void removeUnit(String id) {
    final current =
        widget.quantityAssign[widget.product.name]![id] ?? 0;

    if (current <= 0) return;

    setState(() {
      widget.quantityAssign[widget.product.name]![id] =
          current - 1;
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final total = p.price * p.quantity;

    final selectedCount = widget.selected[p.name]!
        .values
        .where((v) => v)
        .length;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "€${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "${p.quantity} unidade(s) • €${p.price} cada",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 SWITCH
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text(
                  splitMode
                      ? "Dividir por conta"
                      : "Distribuir por unidades",
                  style: const TextStyle(fontSize: 14),
                ),
                value: splitMode,
                onChanged: (v) {
                  setState(() => splitMode = v);
                },
              ),
            ),

            const SizedBox(height: 10),

            // =========================
            // 💰 MODO DIVISÃO DE DINHEIRO
            // =========================
            if (splitMode) ...[
              const Text(
                "Seleciona quem paga:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              ...widget.people.map((person) {
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(person.name),
                  value: widget.selected[p.name]![person.id],
                  onChanged: (v) =>
                      togglePerson(person.id, v!),
                );
              }),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selectedCount == 0
                      ? "Nenhuma pessoa selecionada"
                      : "≈ €${(total / selectedCount).toStringAsFixed(2)} por pessoa",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // =========================
            // 📦 MODO QUANTIDADE
            // =========================
            if (!splitMode) ...[
              const Text(
                "Distribuir unidades:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              ...widget.people.map((person) {
                final qty =
                    widget.quantityAssign[p.name]![person.id] ?? 0;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(person.name),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () =>
                                removeUnit(person.id),
                          ),
                          Text(qty.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => addUnit(person.id),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}