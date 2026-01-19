import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/meal_logger_repository.dart';
import '../../domain/models/logged_meal.dart';
import '../../domain/models/recipe.dart';

// Repository provider
final mealLoggerRepositoryProvider = Provider<MealLoggerRepository>((ref) {
  return MealLoggerRepository();
});

// All logged meals provider
final loggedMealsProvider = StreamProvider<List<LoggedMeal>>((ref) {
  final repository = ref.watch(mealLoggerRepositoryProvider);
  return repository.getLoggedMeals();
});

// Logged meals by date provider
final loggedMealsByDateProvider =
    StreamProvider.family<List<LoggedMeal>, DateTime>((ref, date) {
      final repository = ref.watch(mealLoggerRepositoryProvider);
      return repository.getLoggedMealsByDate(date);
    });

// Meal logger actions provider
final mealLoggerProvider = Provider<MealLoggerActions>((ref) {
  final repository = ref.watch(mealLoggerRepositoryProvider);
  return MealLoggerActions(repository);
});

// Alias for consistent naming with other action providers
final mealLoggerActionsProvider = mealLoggerProvider;

// Meal logger actions service class
class MealLoggerActions {
  final MealLoggerRepository _repository;

  MealLoggerActions(this._repository);

  Future<LoggedMeal> logMeal(Recipe recipe, int servings) async {
    return _repository.logMeal(recipe, servings);
  }

  Future<void> deleteMeal(String mealId) async {
    return _repository.deleteMeal(mealId);
  }

  Stream<List<LoggedMeal>> getLoggedMeals() {
    return _repository.getLoggedMeals();
  }

  Stream<List<LoggedMeal>> getLoggedMealsByDate(DateTime date) {
    return _repository.getLoggedMealsByDate(date);
  }
}
