import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/logged_meal.dart';
import '../../data/dummy/dummy_recipes.dart';
import '../../data/services/yummly_service.dart';

// Recipe data provider - returns dummy recipes
final recipesProvider = Provider<List<Recipe>>((ref) {
  return getDummyRecipes();
});

// Fetch recipes by category (with Yummly API fallback)
final recipesByCategoryProvider = FutureProvider.family<List<Recipe>, String>((
  ref,
  category,
) async {
  // Try API first
  final apiRecipes = await YummlyService.fetchRecipesByCategory(category);

  // Fallback to dummy data if API returns empty
  if (apiRecipes.isNotEmpty) {
    return apiRecipes;
  }

  // Return dummy recipes filtered by category
  final allRecipes = ref.watch(recipesProvider);
  return allRecipes.where((r) => r.category == category).toList();
});

// Search recipes provider
final searchRecipesProvider = FutureProvider.family<List<Recipe>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) {
    return [];
  }

  // Try API first
  final apiRecipes = await YummlyService.searchRecipes(query);

  // Fallback to local search
  if (apiRecipes.isNotEmpty) {
    return apiRecipes;
  }

  // Local search fallback
  final allRecipes = ref.watch(recipesProvider);
  return allRecipes
      .where(
        (r) =>
            r.title.toLowerCase().contains(query.toLowerCase()) ||
            r.ingredients.any(
              (i) => i.name.toLowerCase().contains(query.toLowerCase()),
            ),
      )
      .toList();
});

// Favorites provider (StateNotifier for managing favorite recipes)
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
      (ref) => FavoritesNotifier(),
    );

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  void addFavorite(String recipeId) {
    if (!state.contains(recipeId)) {
      state = [...state, recipeId];
    }
  }

  void removeFavorite(String recipeId) {
    state = state.where((id) => id != recipeId).toList();
  }

  bool isFavorite(String recipeId) {
    return state.contains(recipeId);
  }
}

// Categories provider
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<String>>(
      (ref) => CategoriesNotifier(),
    );

class CategoriesNotifier extends StateNotifier<List<String>> {
  CategoriesNotifier()
    : super([
        'Breakfast',
        'Lunch',
        'Dinner',
        'Desserts',
        'Bakery',
        'Snacks',
        'Drinks',
      ]);

  void addCategory(String category) {
    if (!state.contains(category)) {
      state = [...state, category];
    }
  }

  void removeCategory(String category) {
    state = state.where((c) => c != category).toList();
  }
}

// Shopping list provider
final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
      (ref) => ShoppingListNotifier(),
    );

class ShoppingItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  bool isPurchased;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isPurchased = false,
  });

  ShoppingItem copyWith({bool? isPurchased, double? quantity}) {
    return ShoppingItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      unit: unit,
      category: category,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier() : super([]);

  void addItem(ShoppingItem item) {
    // Check if item already exists
    final existingIndex = state.indexWhere((i) => i.name == item.name);
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        ShoppingItem(
          id: existing.id,
          name: existing.name,
          quantity: existing.quantity + item.quantity,
          unit: existing.unit,
          category: existing.category,
          isPurchased: existing.isPurchased,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
  }

  void updateItem(String itemId, double newQuantity) {
    state = state
        .map(
          (item) =>
              item.id == itemId ? item.copyWith(quantity: newQuantity) : item,
        )
        .toList();
  }

  void togglePurchased(String itemId) {
    state = state
        .map(
          (item) => item.id == itemId
              ? item.copyWith(isPurchased: !item.isPurchased)
              : item,
        )
        .toList();
  }

  void clearPurchased() {
    state = state.where((item) => !item.isPurchased).toList();
  }
}

// Recent recipes provider
final recentRecipesProvider =
    StateNotifierProvider<RecentRecipesNotifier, List<String>>(
      (ref) => RecentRecipesNotifier(),
    );

class RecentRecipesNotifier extends StateNotifier<List<String>> {
  RecentRecipesNotifier() : super([]);

  void addRecent(String recipeId) {
    final filtered = state.where((id) => id != recipeId).toList();
    state = [recipeId, ...filtered];
    // Keep only last 10
    if (state.length > 10) {
      state = state.sublist(0, 10);
    }
  }
}

// Meal logger provider - manages logged meals for nutrition tracking
final mealLoggerProvider =
    StateNotifierProvider<MealLoggerNotifier, List<LoggedMeal>>(
      (ref) => MealLoggerNotifier(),
    );

class MealLoggerNotifier extends StateNotifier<List<LoggedMeal>> {
  MealLoggerNotifier() : super([]);

  /// Add a logged meal
  void addMeal(LoggedMeal meal) {
    state = [...state, meal];
  }

  /// Remove a logged meal by ID
  void removeMeal(String mealId) {
    state = state.where((meal) => meal.id != mealId).toList();
  }

  /// Get all logged meals for a specific date
  List<LoggedMeal> getMealsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return state.where((meal) => meal.dateOnly == dateOnly).toList();
  }

  /// Calculate daily totals for a specific date
  Map<String, double> calculateDailyTotals(DateTime date) {
    final meals = getMealsForDate(date);
    return {
      'calories': meals.fold(0, (sum, meal) => sum + meal.totalCalories),
      'protein': meals.fold(0, (sum, meal) => sum + meal.totalProtein),
      'carbs': meals.fold(0, (sum, meal) => sum + meal.totalCarbs),
      'fats': meals.fold(0, (sum, meal) => sum + meal.totalFats),
    };
  }

  /// Get total calories for a date
  double getTotalCaloriesForDate(DateTime date) {
    return calculateDailyTotals(date)['calories'] ?? 0;
  }

  /// Clear all meals for a date
  void clearMealsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    state = state.where((meal) => meal.dateOnly != dateOnly).toList();
  }
}
