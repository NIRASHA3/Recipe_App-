import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/logged_meal.dart';
import '../../domain/models/recipe.dart';

class MealLoggerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Log a meal
  Future<LoggedMeal> logMeal(Recipe recipe, int servings) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final recipeImageUrl = recipe.imageUrl;

      final mealRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('logged_meals')
          .doc();

      final meal = LoggedMeal(
        id: mealRef.id,
        recipeId: recipe.id,
        recipeTitle: recipe.title,
        recipeImage: recipeImageUrl != null && recipeImageUrl.isNotEmpty
            ? recipeImageUrl
            : null,
        servings: servings,
        loggedAt: DateTime.now(),
        caloriesPerServing: recipe.nutrition.calories,
        proteinPerServing: recipe.nutrition.protein,
        carbsPerServing: recipe.nutrition.carbs,
        fatsPerServing: recipe.nutrition.fats,
        fiberPerServing: recipe.nutrition.fiber,
        sugarPerServing: recipe.nutrition.sugar,
      );

      await mealRef.set(meal.toFirestore());
      return meal;
    } catch (e) {
      throw Exception('Failed to log meal: $e');
    }
  }

  // Get all logged meals for current user
  Stream<List<LoggedMeal>> getLoggedMeals() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('logged_meals')
          .orderBy('loggedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => LoggedMeal.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get logged meals: $e');
    }
  }

  // Get logged meals for a specific date
  Stream<List<LoggedMeal>> getLoggedMealsByDate(DateTime date) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('logged_meals')
          .where(
            'loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('loggedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => LoggedMeal.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get logged meals by date: $e');
    }
  }

  // Delete a logged meal
  Future<void> deleteMeal(String mealId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('logged_meals')
          .doc(mealId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }
}
