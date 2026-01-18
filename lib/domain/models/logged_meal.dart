import 'package:uuid/uuid.dart';
import 'recipe.dart';

class LoggedMeal {
  final String id;
  final Recipe recipe;
  final int servings;
  final DateTime loggedAt;
  final double caloriesPerServing;

  LoggedMeal({
    String? id,
    required this.recipe,
    required this.servings,
    required this.loggedAt,
    double? caloriesPerServing,
  }) : id = id ?? const Uuid().v4(),
       caloriesPerServing = caloriesPerServing ?? recipe.nutrition.calories;

  /// Calculate total calories for logged servings
  double get totalCalories => recipe.nutrition.calories * servings;

  /// Calculate total protein for logged servings
  double get totalProtein => recipe.nutrition.protein * servings;

  /// Calculate total carbs for logged servings
  double get totalCarbs => recipe.nutrition.carbs * servings;

  /// Calculate total fats for logged servings
  double get totalFats => recipe.nutrition.fats * servings;

  /// Get date only (without time)
  DateTime get dateOnly =>
      DateTime(loggedAt.year, loggedAt.month, loggedAt.day);

  factory LoggedMeal.fromJson(Map<String, dynamic> json) {
    return LoggedMeal(
      id: json['id'] as String?,
      recipe: json['recipe'] as Recipe,
      servings: json['servings'] as int,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe,
      'servings': servings,
      'loggedAt': loggedAt.toIso8601String(),
      'caloriesPerServing': caloriesPerServing,
    };
  }

  LoggedMeal copyWith({
    String? id,
    Recipe? recipe,
    int? servings,
    DateTime? loggedAt,
    double? caloriesPerServing,
  }) {
    return LoggedMeal(
      id: id ?? this.id,
      recipe: recipe ?? this.recipe,
      servings: servings ?? this.servings,
      loggedAt: loggedAt ?? this.loggedAt,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
    );
  }
}
