import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/product.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import '../widgets/section_card.dart';
import '../widgets/toast_helper.dart';
import 'assign_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Person> people = [];
  List<Product> products = [];

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

  people.add(
    Person(id: DateTime.now().toString(), name: name),
  );

  nameC.clear();

  setState(() {});
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

  products.add(Product(
    name: name,
    price: price,
    quantity: qty,
  ));

  prodC.clear();
  priceC.clear();
  qtyC.clear();

  setState(() {});
  ToastHelper.show(context, "Produto adicionado");
}

  void go() {
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
      builder: (_) => AssignScreen(
        people: people,
        products: products,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
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