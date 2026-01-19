import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastefit/domain/models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionPath = 'recipes';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new recipe
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      // Add createdBy field and ensure createdAt is set
      final recipeWithUser = recipe.copyWith(
        createdBy: _currentUserId,
        createdAt: DateTime.now(), // Ensure createdAt is not null
        updatedAt: null,
      );

      // Convert to Firestore map
      final data = recipeWithUser.toFirestore();

      // Add to Firestore
      await _firestore
          .collection(_collectionPath)
          .doc(recipeWithUser.id)
          .set(data);

      return recipeWithUser;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  // Update an existing recipe
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      // Add updated timestamp
      final updatedRecipe = recipe.copyWith(updatedAt: DateTime.now());

      final data = updatedRecipe.toFirestore();

      await _firestore
          .collection(_collectionPath)
          .doc(updatedRecipe.id)
          .update(data);

      return updatedRecipe;
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection(_collectionPath).doc(recipeId).delete();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Get a single recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(recipeId)
          .get();

      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  // Watch a single recipe by ID (real-time updates)
  Stream<Recipe?> watchRecipe(String recipeId) {
    try {
      return _firestore
          .collection(_collectionPath)
          .doc(recipeId)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              return Recipe.fromFirestore(snapshot);
            }
            return null;
          });
    } catch (e) {
      throw Exception('Failed to watch recipe: $e');
    }
  }

  // Get all recipes (stream for real-time updates)
  Stream<List<Recipe>> getAllRecipes() {
    try {
      return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
        final recipes = snapshot.docs
            .map((doc) {
              try {
                return Recipe.fromFirestore(doc);
              } catch (e) {
                return null;
              }
            })
            .where((recipe) => recipe != null)
            .cast<Recipe>()
            .toList();

        // Sort in memory instead of using Firestore orderBy
        recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return recipes;
      });
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  // Get recipes by category
  Stream<List<Recipe>> getRecipesByCategory(String categoryId) {
    try {
      return _firestore
          .collection(_collectionPath)
          .where('categoryId', isEqualTo: categoryId)
          .snapshots()
          .map((snapshot) {
            final recipes = snapshot.docs
                .map((doc) {
                  try {
                    return Recipe.fromFirestore(doc);
                  } catch (e) {
                    return null;
                  }
                })
                .where((recipe) => recipe != null)
                .cast<Recipe>()
                .toList();

            // Sort in memory instead of using Firestore orderBy to avoid index issues
            recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return recipes;
          });
    } catch (e) {
      throw Exception('Failed to get recipes by category: $e');
    }
  }

  // Search recipes by title or ingredients
  Stream<List<Recipe>> searchRecipes(String query) {
    try {
      final normalizedQuery = query.trim().toLowerCase();

      if (normalizedQuery.isEmpty) {
        return getAllRecipes();
      }

      return getAllRecipes().map((recipes) {
        return recipes.where((recipe) {
          final titleMatch = recipe.title.toLowerCase().contains(
            normalizedQuery,
          );
          final categoryMatch =
              recipe.category.toLowerCase().contains(normalizedQuery) ||
              recipe.categoryId.toLowerCase().contains(normalizedQuery);
          final ingredientMatch = recipe.ingredients.any(
            (ingredient) =>
                ingredient.name.toLowerCase().contains(normalizedQuery),
          );
          final descriptionMatch = recipe.description.toLowerCase().contains(
            normalizedQuery,
          );

          return titleMatch ||
              categoryMatch ||
              ingredientMatch ||
              descriptionMatch;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  // Get user's favorite recipes
  Stream<List<Recipe>> getUserFavorites(List<String> favoriteIds) {
    try {
      if (favoriteIds.isEmpty) return Stream.value([]);

      return _firestore
          .collection(_collectionPath)
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Recipe.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get favorite recipes: $e');
    }
  }

  // Get recipes count
  Future<int> getRecipesCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .count()
          .get();

      return snapshot.count ?? 0; // Handle null count
    } catch (e) {
      return 0;
    }
  }
}
