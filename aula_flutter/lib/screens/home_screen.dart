import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/person.dart';
import '../models/product.dart';
import '../state/providers.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import '../widgets/section_card.dart';
import '../widgets/toast_helper.dart';
import 'assign_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final nameC = TextEditingController();
  final prodC = TextEditingController();
  final priceC = TextEditingController();
  final qtyC = TextEditingController();

  void addPerson() {
    final name = nameC.text.trim();

    if (name.isEmpty) {
      ToastHelper.show(context, "Nome inválido");
      return;
    }

    final p = Person(id: DateTime.now().toString(), name: name);
    ref.read(peopleProvider.notifier).add(p);

  // ensure selection/units maps include this new person
  ref.read(selectedProvider.notifier).addPerson(p.id);
  ref.read(unitsProvider.notifier).addPerson(p.id);

    nameC.clear();
    ToastHelper.show(context, "Pessoa adicionada");
  }

  void addProduct() {
    final name = prodC.text.trim();
    final price = double.tryParse(priceC.text);
    final qty = int.tryParse(qtyC.text);

    if (name.isEmpty || price == null || qty == null) {
      ToastHelper.show(context, "Campos inválidos");
      return;
    }

    if (price <= 0 || qty <= 0) {
      ToastHelper.show(context, "Preço e quantidade devem ser > 0");
      return;
    }

    final prod = Product(name: name, price: price, quantity: qty);
    ref.read(productsProvider.notifier).add(prod);

  // initialize selected/units for this new product with existing people
  final people = ref.read(peopleProvider);
  ref.read(selectedProvider.notifier).initProduct(prod.name, people);
  ref.read(unitsProvider.notifier).initProduct(prod.name, people);

    prodC.clear();
    priceC.clear();
    qtyC.clear();

    ToastHelper.show(context, "Produto adicionado");
  }

  void go() {
    final people = ref.read(peopleProvider);
    final products = ref.read(productsProvider);

    if (people.length < 2) {
      ToastHelper.show(context, "Precisas de pelo menos 2 pessoas");
      return;
    }

    if (products.isEmpty) {
      ToastHelper.show(context, "Precisas de pelo menos 1 produto");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssignScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Split Bill")),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          SectionCard(
            title: "Pessoas (${people.length})",
            child: Column(
              children: [
                AppTextField(label: "Nome", controller: nameC),
                const SizedBox(height: 10),
                AppButton(text: "Adicionar", onPressed: addPerson, icon: Icons.person_add),
              ],
            ),
          ),

          SectionCard(
            title: "Produtos (${products.length})",
            child: Column(
              children: [
                AppTextField(label: "Produto", controller: prodC),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: "Preço", controller: priceC, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    SizedBox(width: 100, child: AppTextField(label: "Qtd", controller: qtyC, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                AppButton(text: "Adicionar produto", onPressed: addProduct, icon: Icons.add_shopping_cart),
              ],
            ),
          ),

          const SizedBox(height: 6),
          AppButton(
            text: "Continuar",
            icon: Icons.arrow_forward,
            onPressed: go,
          ),
          
        ],
      ),
    );
  }
}