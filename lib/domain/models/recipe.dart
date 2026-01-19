/// Recipe Domain Models
///
/// Defines the data models for recipes including:
/// - Nutrition: Nutritional information for recipes
/// - Ingredient: Individual recipe ingredients with quantity and unit
/// - Recipe: Complete recipe with ingredients, instructions, and metadata
///
library;
import 'package:cloud_firestore/cloud_firestore.dart';

class Nutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;

  /// Nutritional information for a recipe or meal
  const Nutrition({
    this.calories = 200.0,
    this.protein = 10.0,
    this.carbs = 30.0,
    this.fats = 5.0,
    this.fiber = 3.0,
    this.sugar = 5.0,
  });

  factory Nutrition.fromMap(Map<String, dynamic> map) {
    return Nutrition(
      calories: (map['calories'] ?? 200.0).toDouble(),
      protein: (map['protein'] ?? 10.0).toDouble(),
      carbs: (map['carbs'] ?? 30.0).toDouble(),
      fats: (map['fats'] ?? 5.0).toDouble(),
      fiber: (map['fiber'] ?? 3.0).toDouble(),
      sugar: (map['sugar'] ?? 5.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
    };
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String categoryId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final Difficulty difficulty;
  final Nutrition nutrition;
  final double? rating;
  final String category;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.categoryId,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    Nutrition? nutrition,
    this.rating,
    this.category = '',
  }) : nutrition = nutrition ?? const Nutrition();

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle ingredients list
    final ingredients = (data['ingredients'] as List<dynamic>? ?? [])
        .map((item) => Ingredient.fromMap(item))
        .toList();

    // Handle instructions list
    final instructions = (data['instructions'] as List<dynamic>? ?? [])
        .cast<String>()
        .toList();

    // Handle nutrition data
    final nutrition = data['nutrition'] != null
        ? Nutrition.fromMap(data['nutrition'] as Map<String, dynamic>)
        : const Nutrition();

    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      ingredients: ingredients,
      instructions: instructions,
      categoryId: data['categoryId'] ?? '',
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      servings: data['servings'] ?? 1,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (data['difficulty'] ?? 'easy'),
        orElse: () => Difficulty.easy,
      ),
      nutrition: nutrition,
      rating: data['rating']?.toDouble(),
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'categoryId': categoryId,
      if (createdBy != null) 'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty.name,
      'nutrition': nutrition.toMap(),
      if (rating != null) 'rating': rating,
      'category': category,
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    String? categoryId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? prepTime,
    int? cookTime,
    int? servings,
    Difficulty? difficulty,
    Nutrition? nutrition,
    double? rating,
    String? category,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      categoryId: categoryId ?? this.categoryId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      nutrition: nutrition ?? this.nutrition,
      rating: rating ?? this.rating,
      category: category ?? this.category,
    );
  }
}

enum Difficulty { easy, medium, hard }

// Getters for Recipe compatibility
extension RecipeGetters on Recipe {
  int get prepTimeMinutes => prepTime;
  int get cookTimeMinutes => cookTime;
  double get totalTime => (prepTime + cookTime).toDouble();
}

class Ingredient {
  final String id;
  final String name;
  final int quantity;
  final String? unit; // Optional: not needed for countable items like eggs
  final String? category;

  Ingredient({
    String? id,
    required this.name,
    required this.quantity,
    this.unit,
    this.category,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      unit: map['unit'], // Can be null
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
    };
  }
}
