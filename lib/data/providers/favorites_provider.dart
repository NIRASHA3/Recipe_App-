import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/favorites_repository.dart';

// Repository provider
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

// Favorites stream provider
final favoritesProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteIds();
});

// Favorites actions provider
final favoritesActionsProvider = Provider<FavoritesActions>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesActions(repository);
});

// Favorites actions service class
class FavoritesActions {
  final FavoritesRepository _repository;

  FavoritesActions(this._repository);

  Future<void> addFavorite(String recipeId) async {
    return _repository.addFavorite(recipeId);
  }

  Future<void> removeFavorite(String recipeId) async {
    return _repository.removeFavorite(recipeId);
  }

  Future<void> toggleFavorite(String recipeId, bool isFavorite) async {
    if (isFavorite) {
      await _repository.removeFavorite(recipeId);
    } else {
      await _repository.addFavorite(recipeId);
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    return _repository.isFavorite(recipeId);
  }

  Stream<List<String>> getFavoriteIds() {
    return _repository.getFavoriteIds();
  }
}
