import 'pessoas.dart';

enum SplitMode { perUnit, equal }

class Item {
  String name;
  double price;
  int quantity;

  // 🔥 consumo por pessoa (quantas unidades)
  Map<Person, int> consumption;

  // pessoas que partilham no modo equal
  List<Person> sharedBy;

  SplitMode splitMode;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
  })  : consumption = {},
        sharedBy = [],
        splitMode = SplitMode.perUnit;
}