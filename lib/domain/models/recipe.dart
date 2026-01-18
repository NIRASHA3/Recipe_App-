import 'package:uuid/uuid.dart';
import 'ingredient.dart';
import 'nutrition_info.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final NutritionInfo nutrition;
  final String? imageUrl; // For Cloudinary URL (placeholder for now)
  final double? rating; // Optional rating
  final bool isFavorite;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.nutrition,
    this.imageUrl,
    this.rating,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    NutritionInfo? nutrition,
    String? imageUrl,
    double? rating,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      nutrition: nutrition ?? this.nutrition,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  List<Object?> get props => [
    id,
    title,
    category,
    ingredients,
    instructions,
    prepTimeMinutes,
    cookTimeMinutes,
    servings,
    nutrition,
    imageUrl,
    rating,
    isFavorite,
    createdAt,
  ];
}
