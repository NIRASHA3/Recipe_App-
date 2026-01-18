class NutritionInfo {
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fats; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? sodium; // mg

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber,
    this.sugar,
    this.sodium,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      sugar: json['sugar'] != null ? (json['sugar'] as num).toDouble() : null,
      sodium: json['sodium'] != null ? (json['sodium'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  NutritionInfo copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    double? sugar,
    double? sodium,
  }) {
    return NutritionInfo(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
    );
  }

  @override
  String toString() => 'NutritionInfo(calories: $calories, protein: ${protein}g, carbs: ${carbs}g, fats: ${fats}g)';
}
