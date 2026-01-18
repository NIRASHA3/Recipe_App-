import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/ingredient.dart';
import '../../domain/models/nutrition_info.dart';

class YummlyService {
  static const String _baseUrl = 'https://yummly2.p.rapidapi.com/feeds/list';

  // TODO: Replace with your actual RapidAPI key
  static const String _apiKey = 'YOUR_RAPIDAPI_KEY_HERE';
  static const String _apiHost = 'yummly2.p.rapidapi.com';

  /// Fetch recipes by category tag from Yummly API
  ///
  /// Example tags:
  /// - "list.recipe.mealtype.breakfast"
  /// - "list.recipe.mealtype.lunch"
  /// - "list.recipe.mealtype.dinner"
  /// - "list.recipe.mealtype.dessert"
  /// - "list.recipe.mealtype.snack"
  /// - "list.recipe.cuisine.vegan"
  /// - "list.recipe.diet.low-calorie"
  static Future<List<Recipe>> fetchRecipesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      // Map category names to Yummly tags
      final tag = _getCategoryTag(category);

      final url = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'start': '0',
          'maxResult': limit.toString(),
          'tag': tag,
        },
      );

      final response = await http
          .get(
            url,
            headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final feeds = json['feed'] as List? ?? [];

        return feeds.map((feed) {
          final recipe = feed['recipe'] as Map<String, dynamic>;
          return _parseRecipe(recipe, category);
        }).toList();
      } else if (response.statusCode == 429) {
        // Rate limited - return empty list which will trigger fallback to dummy data
        if (kDebugMode) {
          print(
            'Yummly API Rate Limited (429) for category $category. Using dummy data...',
          );
        }
        return [];
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list on error; app will use dummy data as fallback
      if (kDebugMode) {
        print('Yummly API Error: $e');
      }
      return [];
    }
  }

  /// Convert category name to Yummly API tag
  static String _getCategoryTag(String category) {
    const categoryMap = {
      'Breakfast': 'list.recipe.mealtype.breakfast',
      'Lunch': 'list.recipe.mealtype.lunch',
      'Dinner': 'list.recipe.mealtype.dinner',
      'Desserts': 'list.recipe.mealtype.dessert',
      'Bakery': 'list.recipe.cuisine.bakery',
      'Snacks': 'list.recipe.mealtype.snack',
      'Drinks': 'list.recipe.mealtype.beverage',
    };
    return categoryMap[category] ?? 'list.recipe.mealtype.lunch';
  }

  /// Parse Yummly recipe JSON to Recipe model
  static Recipe _parseRecipe(Map<String, dynamic> json, String category) {
    final recipeData = json;
    final title = recipeData['label'] as String? ?? 'Unknown Recipe';
    final ingredients = _parseIngredients(
      recipeData['ingredientLines'] as List? ?? [],
    );
    final imageUrl = recipeData['image'] as String?;
    final nutrition = _parseNutrition(
      recipeData['totalNutrients'] as Map? ?? {},
    );

    // Extract time in minutes (Yummly provides in minutes)
    final totalTime = recipeData['totalTime'] as int? ?? 30;
    final prepTime = (totalTime * 0.3).toInt();
    final cookTime = totalTime - prepTime;

    // Extract rating (0-5 scale)
    final rating = (recipeData['rating'] as num?)?.toDouble() ?? 0.0;

    return Recipe(
      title: title,
      category: category,
      ingredients: ingredients,
      instructions: _parseInstructions(
        recipeData['instructions'] as List? ?? [],
      ),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: recipeData['yield'] as int? ?? 1,
      nutrition: nutrition,
      imageUrl: imageUrl,
      rating: rating > 0 ? rating : null,
      isFavorite: false,
    );
  }

  /// Parse ingredients from Yummly format
  static List<Ingredient> _parseIngredients(List ingredients) {
    return ingredients.map<Ingredient>((item) {
      if (item is Map<String, dynamic>) {
        final food = item['food'] as Map<String, dynamic>? ?? {};
        final measure = item['measure'] as Map<String, dynamic>? ?? {};

        return Ingredient(
          name: food['label'] as String? ?? 'Ingredient',
          quantity: (item['quantity'] as num?)?.toDouble() ?? 1.0,
          unit: measure['label'] as String? ?? '',
        );
      }
      return Ingredient(name: item.toString(), quantity: 1, unit: '');
    }).toList();
  }

  /// Parse instructions from Yummly format
  static List<String> _parseInstructions(List instructions) {
    return instructions
        .map<String>((item) {
          if (item is Map<String, dynamic>) {
            return item['steps'] as String? ?? '';
          }
          return item.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Parse nutrition information from Yummly format
  static NutritionInfo _parseNutrition(Map nutrients) {
    double getnutrient(String key) {
      final value = nutrients[key] as Map?;
      return (value?['quantity'] as num?)?.toDouble() ?? 0.0;
    }

    return NutritionInfo(
      calories: getnutrient('ENERC_KCAL'),
      protein: getnutrient('PROCNT'),
      carbs: getnutrient('CHOCDF'),
      fats: getnutrient('FAT'),
      fiber: getnutrient('FIBTG') > 0 ? getnutrient('FIBTG') : null,
      sugar: getnutrient('SUGAR') > 0 ? getnutrient('SUGAR') : null,
      sodium: getnutrient('NA'),
    );
  }

  /// Search recipes by query string
  static Future<List<Recipe>> searchRecipes(
    String query, {
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'q': query,
          'start': '0',
          'maxResult': limit.toString(),
        },
      );

      final response = await http
          .get(
            url,
            headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final feeds = json['feed'] as List? ?? [];

        return feeds.map((feed) {
          final recipe = feed['recipe'] as Map<String, dynamic>;
          return _parseRecipe(recipe, 'Search Result');
        }).toList();
      } else if (response.statusCode == 429) {
        // Rate limited - return empty list which will trigger fallback to local search
        if (kDebugMode) {
          print('Yummly API Rate Limited (429). Using local search...');
        }
        return [];
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Yummly Search Error: $e');
      }
      return [];
    }
  }
}
