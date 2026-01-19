// lib/data/repositories/category_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastefit/domain/models/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionPath = 'categories';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new category
  Future<Category> createCategory(Category category) async {
    try {
      // Add createdBy field
      final categoryWithUser = category.copyWith(createdBy: _currentUserId);

      // Convert to Firestore map
      final data = categoryWithUser.toFirestore();

      // Add to Firestore
      await _firestore
          .collection(_collectionPath)
          .doc(categoryWithUser.id)
          .set(data);

      return categoryWithUser;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update an existing category
  Future<Category> updateCategory(Category category) async {
    try {
      // Add updated timestamp
      final updatedCategory = category.copyWith(updatedAt: DateTime.now());

      final data = updatedCategory.toFirestore();

      await _firestore
          .collection(_collectionPath)
          .doc(updatedCategory.id)
          .update(data);

      return updatedCategory;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      // First check if category has recipes
      final recipesSnapshot = await _firestore
          .collection('recipes')
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();

      if (recipesSnapshot.docs.isNotEmpty) {
        throw Exception('Cannot delete category with existing recipes');
      }

      await _firestore.collection(_collectionPath).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Get a single category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  // Get all categories (stream for real-time updates)
  Stream<List<Category>> getAllCategories() {
    try {
      return _firestore
          .collection(_collectionPath)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Get default categories only
  Stream<List<Category>> getDefaultCategories() {
    try {
      return _firestore
          .collection(_collectionPath)
          .where('isCustom', isEqualTo: false)
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get default categories: $e');
    }
  }

  // Get custom categories only
  Stream<List<Category>> getCustomCategories() {
    try {
      final userId = _currentUserId;
      if (userId == null) return const Stream.empty();

      return _firestore
          .collection(_collectionPath)
          .where('isCustom', isEqualTo: true)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get custom categories: $e');
    }
  }

  // Search categories by name
  Stream<List<Category>> searchCategories(String query) {
    try {
      // Note: Firestore doesn't support case-insensitive search directly
      // This will search for exact matches
      return _firestore
          .collection(_collectionPath)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to search categories: $e');
    }
  }

  // Get categories with most recipes
  Stream<List<Category>> getPopularCategories({int limit = 5}) {
    try {
      return _firestore
          .collection(_collectionPath)
          .orderBy('recipeCount', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get popular categories: $e');
    }
  }

  // Update recipe count for a category
  Future<void> updateRecipeCount(String categoryId, int change) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(categoryId)
          .get();

      if (doc.exists) {
        final currentCount = (doc.data()?['recipeCount'] as num?)?.toInt() ?? 0;
        final newCount = currentCount + change;

        if (newCount >= 0) {
          await doc.reference.update({
            'recipeCount': newCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update recipe count: $e');
    }
  }

  // Check if category name already exists
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collectionPath)
          .where('name', isEqualTo: name);

      if (excludeId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
      }

      final snapshot = await query.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category name: $e');
    }
  }

  // Get categories by IDs
  Future<List<Category>> getCategoriesByIds(List<String> categoryIds) async {
    try {
      if (categoryIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection(_collectionPath)
          .where(FieldPath.documentId, whereIn: categoryIds)
          .get();

      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get categories by IDs: $e');
    }
  }

  // Get categories count - FIXED: Returns int instead of int?
  Future<int?> getCategoriesCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .count()
          .get();

      return snapshot.count;
    } catch (e) {
      throw Exception('Failed to get categories count: $e');
    }
  }
}
