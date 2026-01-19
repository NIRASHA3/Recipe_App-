import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Add to favorites
  Future<void> addFavorite(String recipeId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(recipeId)
          .set({'recipeId': recipeId, 'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String recipeId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Get all favorite recipe IDs
  Stream<List<String>> getFavoriteIds() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => doc.id).toList();
          });
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Check if recipe is favorite
  Future<bool> isFavorite(String recipeId) async {
    if (_currentUserId == null) {
      return false;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(recipeId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
