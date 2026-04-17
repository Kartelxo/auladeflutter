import 'pessoas.dart';
class Item {
  final String id;
  String nome;
  double preco;
  final List<Person> consumers;

  Item({
    required this.id,
    required this.nome,
    required this.preco,
    required this.consumers});
}