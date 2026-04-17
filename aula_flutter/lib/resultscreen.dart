import 'package:flutter/material.dart';
import '../models/pessoas.dart';
import '../models/produtos.dart';

class ResultScreen extends StatelessWidget {
  final List<Person> people;
  final List<Item> items;

  const ResultScreen({
    super.key,
    required this.people,
    required this.items,
  });

  /// 🔥 divide centimos e distribui resto pelos primeiros
  List<int> splitCents(int totalCents, int peopleCount) {
    int base = totalCents ~/ peopleCount;
    int remainder = totalCents % peopleCount;

    List<int> result = List.filled(peopleCount, base);

    for (int i = 0; i < remainder; i++) {
      result[i] += 1;
    }

    return result;
  }

  Map<Person, double> calculateTotals() {
    Map<Person, double> totals = {for (var p in people) p: 0};

    for (var item in items) {

      /// 🔵 MODO POR UNIDADE
      if (item.splitMode == SplitMode.perUnit) {
        int unitCents = ((item.price / item.quantity) * 100).round();

        item.consumption.forEach((person, qty) {
          int totalCents = unitCents * qty;

          totals[person] =
              totals[person]! + (totalCents / 100);
        });
      }

      /// 🟢 MODO DIVIDIR CONTA (COM RESTO DISTRIBUÍDO)
      else {
        if (item.sharedBy.isEmpty) continue;

        int totalCents = (item.price * 100).round();
        List<Person> group = item.sharedBy;

        List<int> split = splitCents(totalCents, group.length);

        for (int i = 0; i < group.length; i++) {
          totals[group[i]] =
              totals[group[i]]! + (split[i] / 100);
        }
      }
    }

    return totals;
  }

  double totalBill() {
    double total = 0;
    for (var item in items) {
      total += item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals();

    return Scaffold(
      appBar: AppBar(title: const Text("Resultado Final 💰")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 💰 TOTAL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Total da Conta",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${totalBill().toStringAsFixed(2)} €",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Quanto cada pessoa paga",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// LISTA
            Expanded(
              child: ListView(
                children: totals.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(entry.key.name),
                      trailing: Text(
                        "${entry.value.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            /// BOTÃO NOVA CONTA
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Nova Conta"),
            ),
          ],
        ),
      ),
    );
  }
}