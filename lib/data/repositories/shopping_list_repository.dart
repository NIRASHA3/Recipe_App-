import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/shopping_item.dart';

class ShoppingListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Add shopping item
  Future<ShoppingItem> addItem(ShoppingItem item) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final itemRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .doc(item.id);

      await itemRef.set(item.toMap());
      return item;
    } catch (e) {
      throw Exception('Failed to add shopping item: $e');
    }
  }

  // Remove shopping item
  Future<void> removeItem(String itemId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove shopping item: $e');
    }
  }

  // Update shopping item
  Future<void> updateItem(ShoppingItem item) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .doc(item.id)
          .update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update shopping item: $e');
    }
  }

  // Toggle purchased status
  Future<void> togglePurchased(String itemId, bool isPurchased) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .doc(itemId)
          .update({'isPurchased': !isPurchased});
    } catch (e) {
      throw Exception('Failed to toggle purchased status: $e');
    }
  }

  // Get all shopping items
  Stream<List<ShoppingItem>> getAllItems() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .orderBy('isPurchased')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ShoppingItem.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get shopping items: $e');
    }
  }

  // Clear purchased items
  Future<void> clearPurchased() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .where('isPurchased', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear purchased items: $e');
    }
  }

  // Clear all items
  Future<void> clearAll() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('shopping_list')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear all items: $e');
    }
  }
}
