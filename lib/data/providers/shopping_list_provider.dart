/// Shopping List Provider
///
/// Manages shopping list state and actions using Riverpod.
/// Provides stream of shopping items from Firestore and actions for CRUD operations.
///
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/shopping_list_repository.dart';
import '../../domain/models/shopping_item.dart';

// Repository provider
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository();
});

// Shopping list stream provider
final shoppingListProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return repository.getAllItems();
});

// Shopping list actions provider
final shoppingListActionsProvider = Provider<ShoppingListActions>((ref) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return ShoppingListActions(repository);
});

// Shopping list actions service class
class ShoppingListActions {
  final ShoppingListRepository _repository;

  ShoppingListActions(this._repository);

  Future<ShoppingItem> addItem(ShoppingItem item) async {
    return _repository.addItem(item);
  }

  Future<void> removeItem(String itemId) async {
    return _repository.removeItem(itemId);
  }

  Future<void> updateItem(ShoppingItem item) async {
    return _repository.updateItem(item);
  }

  Future<void> togglePurchased(String itemId, bool currentStatus) async {
    return _repository.togglePurchased(itemId, currentStatus);
  }

  Future<void> clearPurchased() async {
    return _repository.clearPurchased();
  }

  Future<void> clearAll() async {
    return _repository.clearAll();
  }

  Stream<List<ShoppingItem>> getAllItems() {
    return _repository.getAllItems();
  }
}
