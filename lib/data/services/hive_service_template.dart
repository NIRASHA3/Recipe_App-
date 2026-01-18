// TODO: Uncomment and implement when Hive integration is needed
// This file serves as a template for Hive box setup and local storage

/*
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'domain/models/recipe.dart';
import 'domain/models/ingredient.dart';
import 'domain/models/nutrition_info.dart';

class HiveService {
  static const String recipesBoxName = 'recipes';
  static const String favoritesBoxName = 'favorites';
  static const String shoppingListBoxName = 'shopping_list';
  static const String categoriesBoxName = 'categories';
  static const String recentRecipesBoxName = 'recent_recipes';

  static Future<void> initializeHive() async {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters (after running build_runner)
    // Hive.registerAdapter(RecipeAdapter());
    // Hive.registerAdapter(IngredientAdapter());
    // Hive.registerAdapter(NutritionInfoAdapter());

    // Open boxes
    await Hive.openBox<Recipe>(recipesBoxName);
    await Hive.openBox<String>(favoritesBoxName);
    await Hive.openBox<dynamic>(shoppingListBoxName);
    await Hive.openBox<String>(categoriesBoxName);
    await Hive.openBox<String>(recentRecipesBoxName);
  }

  static Future<void> saveRecipes(List<Recipe> recipes) async {
    final box = Hive.box<Recipe>(recipesBoxName);
    await box.clear();
    for (var recipe in recipes) {
      await box.put(recipe.id, recipe);
    }
  }

  static List<Recipe> getRecipes() {
    final box = Hive.box<Recipe>(recipesBoxName);
    return box.values.toList();
  }

  static Future<void> saveFavorite(String recipeId) async {
    final box = Hive.box<String>(favoritesBoxName);
    if (!box.values.contains(recipeId)) {
      await box.add(recipeId);
    }
  }

  static Future<void> removeFavorite(String recipeId) async {
    final box = Hive.box<String>(favoritesBoxName);
    final key = box.keys.firstWhere(
      (k) => box.get(k) == recipeId,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  static List<String> getFavorites() {
    final box = Hive.box<String>(favoritesBoxName);
    return box.values.toList();
  }

  static Future<void> addToShoppingList(Map<String, dynamic> item) async {
    final box = Hive.box(shoppingListBoxName);
    await box.add(item);
  }

  static List<Map<String, dynamic>> getShoppingList() {
    final box = Hive.box(shoppingListBoxName);
    return List<Map<String, dynamic>>.from(box.values);
  }

  static Future<void> clearShoppingList() async {
    final box = Hive.box(shoppingListBoxName);
    await box.clear();
  }

  static Future<void> saveCategories(List<String> categories) async {
    final box = Hive.box<String>(categoriesBoxName);
    await box.clear();
    for (var category in categories) {
      await box.add(category);
    }
  }

  static List<String> getCategories() {
    final box = Hive.box<String>(categoriesBoxName);
    return box.values.toList();
  }

  static Future<void> addRecentRecipe(String recipeId) async {
    final box = Hive.box<String>(recentRecipesBoxName);
    // Remove if already exists
    final existingKey = box.keys.firstWhere(
      (k) => box.get(k) == recipeId,
      orElse: () => null,
    );
    if (existingKey != null) {
      await box.delete(existingKey);
    }
    // Add to front
    await box.add(recipeId);
    // Keep only last 10
    if (box.length > 10) {
      await box.deleteAt(0);
    }
  }

  static List<String> getRecentRecipes() {
    final box = Hive.box<String>(recentRecipesBoxName);
    return box.values.toList().reversed.toList();
  }
}
*/
