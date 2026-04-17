import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/person.dart';
import '../models/product.dart';

// People
class PeopleNotifier extends StateNotifier<List<Person>> {
  PeopleNotifier() : super([]);

  void add(Person p) => state = [...state, p];

  void remove(String id) => state = state.where((e) => e.id != id).toList();

  void updateName(String id, String name) {
    state = state.map((p) => p.id == id ? Person(id: p.id, name: name) : p).toList();
  }
}

final peopleProvider = StateNotifierProvider<PeopleNotifier, List<Person>>((ref) => PeopleNotifier());

// Products
class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  void add(Product p) => state = [...state, p];

  void remove(String name) => state = state.where((e) => e.name != name).toList();
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) => ProductsNotifier());

// Computed total
final overallTotalProvider = Provider<double>((ref) {
  final products = ref.watch(productsProvider);
  return products.fold<double>(0, (sum, p) => sum + p.price * p.quantity);
});

// Selected map: productName -> personId -> bool
class SelectedNotifier extends StateNotifier<Map<String, Map<String, bool>>> {
  SelectedNotifier() : super({});

  void initProduct(String productName, List<Person> people) {
    state = {
      ...state,
      productName: {for (var p in people) p.id: false},
    };
  }

  void resetProduct(String productName, List<Person> people) {
    state = {
      ...state,
      productName: {for (var p in people) p.id: false},
    };
  }

  void setSelection(String productName, String personId, bool value) {
    final productMap = Map<String, bool>.from(state[productName] ?? {});
    productMap[personId] = value;
    state = {...state, productName: productMap};
  }
}

final selectedProvider = StateNotifierProvider<SelectedNotifier, Map<String, Map<String, bool>>>((ref) => SelectedNotifier());

// Units map: productName -> personId -> int
class UnitsNotifier extends StateNotifier<Map<String, Map<String, int>>> {
  UnitsNotifier() : super({});

  void initProduct(String productName, List<Person> people) {
    state = {
      ...state,
      productName: {for (var p in people) p.id: 0},
    };
  }

  void resetProduct(String productName, List<Person> people) {
    state = {
      ...state,
      productName: {for (var p in people) p.id: 0},
    };
  }

  void setUnits(String productName, String personId, int value) {
    final productMap = Map<String, int>.from(state[productName] ?? {});
    productMap[personId] = value;
    state = {...state, productName: productMap};
  }
}

final unitsProvider = StateNotifierProvider<UnitsNotifier, Map<String, Map<String, int>>>((ref) => UnitsNotifier());

// Per-product flags: divideEnabled and useUnits
class FlagsNotifier extends StateNotifier<Map<String, bool>> {
  FlagsNotifier() : super({});

  void setFlag(String productName, bool value) {
    state = {...state, productName: value};
  }

  bool getFlag(String productName) => state[productName] ?? false;
}

final divideEnabledProvider = StateNotifierProvider<FlagsNotifier, Map<String, bool>>((ref) => FlagsNotifier());
final useUnitsProvider = StateNotifierProvider<FlagsNotifier, Map<String, bool>>((ref) => FlagsNotifier());

