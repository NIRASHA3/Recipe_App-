// lib/data/providers/recipe_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/models/recipe.dart';

// Repository provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

// All recipes provider
final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getAllRecipes();
});

// Single recipe provider
final recipeProvider = StreamProvider.family<Recipe?, String>((ref, recipeId) async* {
  final repository = ref.read(recipeRepositoryProvider);
  final recipe = await repository.getRecipeById(recipeId);
  if (recipe != null) {
    yield recipe;
  }
});

// Search recipes provider
final searchRecipesProvider = StreamProvider.family<List<Recipe>, String>((ref, query) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.searchRecipes(query);
});

// Category recipes provider
final categoryRecipesProvider = StreamProvider.family<List<Recipe>, String>((ref, categoryId) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipesByCategory(categoryId);
});

// Recipes count provider
final recipesCountProvider = StreamProvider<int>((ref) {
  final recipes = ref.watch(recipesProvider);
  return recipes.maybeWhen(
    data: (recipes) => Stream.value(recipes.length),
    orElse: () => Stream.value(0),
  );
});

// Recipe CRUD operations provider
final recipeActionsProvider = Provider<RecipeActions>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeActions(repository);
});

// Recipe actions service class
class RecipeActions {
  final RecipeRepository _repository;

  RecipeActions(this._repository);

  Future<Recipe> createRecipe(Recipe recipe) async {
    final newRecipe = recipe.copyWith(
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    return _repository.createRecipe(newRecipe);
  }

  Future<Recipe> updateRecipe(Recipe recipe) async {
    final updatedRecipe = recipe.copyWith(
      updatedAt: DateTime.now(),
    );
    return _repository.updateRecipe(updatedRecipe);
  }

  Future<void> deleteRecipe(String recipeId) async {
    return _repository.deleteRecipe(recipeId);
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    return _repository.getRecipeById(recipeId);
  }

  Stream<List<Recipe>> getRecipesByCategory(String categoryId) {
    return _repository.getRecipesByCategory(categoryId);
  }

  Stream<List<Recipe>> searchRecipes(String query) {
    return _repository.searchRecipes(query);
  }
}
