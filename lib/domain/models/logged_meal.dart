import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedMeal {
  final String id;
  final String recipeId;
  final String recipeTitle;
  final String? recipeImage;
  final int servings;
  final DateTime loggedAt;
  final double caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatsPerServing;
  final double fiberPerServing;
  final double sugarPerServing;

  LoggedMeal({
    required this.id,
    required this.recipeId,
    required this.recipeTitle,
    this.recipeImage,
    required this.servings,
    required this.loggedAt,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatsPerServing,
    required this.fiberPerServing,
    required this.sugarPerServing,
  });

  /// Calculate total calories for logged servings
  double get totalCalories => caloriesPerServing * servings;

  /// Calculate total protein for logged servings
  double get totalProtein => proteinPerServing * servings;

  /// Calculate total carbs for logged servings
  double get totalCarbs => carbsPerServing * servings;

  /// Calculate total fats for logged servings
  double get totalFats => fatsPerServing * servings;

  /// Calculate total fiber for logged servings
  double get totalFiber => fiberPerServing * servings;

  /// Calculate total sugar for logged servings
  double get totalSugar => sugarPerServing * servings;

  /// Get date only (without time)
  DateTime get dateOnly =>
      DateTime(loggedAt.year, loggedAt.month, loggedAt.day);

  factory LoggedMeal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoggedMeal(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      recipeTitle: data['recipeTitle'] ?? '',
      recipeImage: data['recipeImage'],
      servings: data['servings'] ?? 1,
      loggedAt: (data['loggedAt'] as Timestamp).toDate(),
      caloriesPerServing: (data['caloriesPerServing'] ?? 0).toDouble(),
      proteinPerServing: (data['proteinPerServing'] ?? 0).toDouble(),
      carbsPerServing: (data['carbsPerServing'] ?? 0).toDouble(),
      fatsPerServing: (data['fatsPerServing'] ?? 0).toDouble(),
      fiberPerServing: (data['fiberPerServing'] ?? 0).toDouble(),
      sugarPerServing: (data['sugarPerServing'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      if (recipeImage != null) 'recipeImage': recipeImage,
      'servings': servings,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'caloriesPerServing': caloriesPerServing,
      'proteinPerServing': proteinPerServing,
      'carbsPerServing': carbsPerServing,
      'fatsPerServing': fatsPerServing,
      'fiberPerServing': fiberPerServing,
      'sugarPerServing': sugarPerServing,
    };
  }

  LoggedMeal copyWith({
    String? id,
    String? recipeId,
    String? recipeTitle,
    String? recipeImage,
    int? servings,
    DateTime? loggedAt,
    double? caloriesPerServing,
    double? proteinPerServing,
    double? carbsPerServing,
    double? fatsPerServing,
    double? fiberPerServing,
    double? sugarPerServing,
  }) {
    return LoggedMeal(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeImage: recipeImage ?? this.recipeImage,
      servings: servings ?? this.servings,
      loggedAt: loggedAt ?? this.loggedAt,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      proteinPerServing: proteinPerServing ?? this.proteinPerServing,
      carbsPerServing: carbsPerServing ?? this.carbsPerServing,
      fatsPerServing: fatsPerServing ?? this.fatsPerServing,
      fiberPerServing: fiberPerServing ?? this.fiberPerServing,
      sugarPerServing: sugarPerServing ?? this.sugarPerServing,
    );
  }
}
