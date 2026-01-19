import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/category.dart';

class DefaultDataInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Default categories for initial setup - using image URLs
  final List<Category> _defaultCategories = [
    Category(
      name: 'Breakfast',
      description: 'Morning meals, smoothies, and energizing recipes to start your day',
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Lunch',
      description: 'Midday meals, salads, and healthy options for your lunch break',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Dinner',
      description: 'Evening meals, main courses, and family dinners',
      imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Desserts',
      description: 'Sweet treats, cakes, cookies, and delightful desserts',
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Snacks',
      description: 'Quick bites, appetizers, and healthy snacks for any time',
      imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Smoothies',
      description: 'Healthy drinks, protein shakes, and nutritious smoothies',
      imageUrl: 'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Salads',
      description: 'Fresh, healthy, and colorful salad recipes',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Vegetarian',
      description: 'Plant-based, vegetarian, and vegan recipes',
      imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Bakery',
      description: 'Breads, pastries, muffins, and baked goods',
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Asian',
      description: 'Asian cuisine including Chinese, Japanese, Thai, and Korean recipes',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d9d6?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Italian',
      description: 'Italian classics: pasta, pizza, risotto, and more',
      imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Mexican',
      description: 'Mexican favorites: tacos, burritos, guacamole, and more',
      imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Mediterranean',
      description: 'Healthy Mediterranean diet recipes',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Healthy',
      description: 'Low-calorie, nutritious, and diet-friendly recipes',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Quick & Easy',
      description: 'Fast recipes that take 30 minutes or less to prepare',
      imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Family Favorites',
      description: 'Kid-friendly recipes loved by the whole family',
      imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Holiday Specials',
      description: 'Recipes perfect for holidays and special occasions',
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Drinks',
      description: 'Refreshing beverages, cocktails, and non-alcoholic drinks',
      imageUrl: 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Soups',
      description: 'Warm and comforting soup recipes for all seasons',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'Seafood',
      description: 'Fish, shrimp, and other seafood recipes',
      imageUrl: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
    Category(
      name: 'All Recipes',
      description: 'Browse all recipes in your collection',
      imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
      isCustom: false,
      recipeCount: 0,
    ),
  ];
  
  // ignore: non_constant_identifier_names
  get CategoryHelper => null;

  // Initialize default categories in Firestore
  Future<void> initializeDefaultCategories({bool force = false}) async {
    try {
      developer.log('Starting default categories initialization...');

      // Check if categories already exist
      final categoriesSnapshot = await _firestore
          .collection('categories')
          .where('isCustom', isEqualTo: false)
          .limit(1)
          .get();

      if (categoriesSnapshot.docs.isNotEmpty && !force) {
        developer.log('Default categories already exist. Skipping initialization.');
        return;
      }

      // Get current user ID (if logged in)
      final userId = _auth.currentUser?.uid ?? 'system_admin';

      // Add each default category
      int addedCount = 0;
      int skippedCount = 0;
      
      for (final category in _defaultCategories) {
        try {
          // Check if category with same name already exists
          final existingCategory = await _firestore
              .collection('categories')
              .where('name', isEqualTo: category.name)
              .limit(1)
              .get();

          if (existingCategory.docs.isEmpty) {
            // Create category with system user ID and current timestamp
            final categoryData = {
              ...category.copyWith(
                createdBy: userId, updatedAt: null,
              ).toFirestore(),
              'createdAt': FieldValue.serverTimestamp(), // Use server timestamp for consistency
            };

            await _firestore
                .collection('categories')
                .doc(category.id)
                .set(categoryData, SetOptions(merge: false));

            addedCount++;
            developer.log('Added category: ${category.name}');
          } else {
            // Update existing category with new fields if needed
            final existingData = existingCategory.docs.first.data();
            final needsUpdate = !existingData.containsKey('description') || 
                               existingData['description'] == null ||
                               !existingData.containsKey('imageUrl') || // Changed from 'icon'
                               existingData['imageUrl'] == null;

            if (needsUpdate) {
              await existingCategory.docs.first.reference.update({
                'description': category.description,
                'imageUrl': category.imageUrl, // Changed from 'icon'
                'recipeCount': existingData['recipeCount'] ?? 0,
              });
              developer.log('Updated category: ${category.name}');
            }
            skippedCount++;
          }
        } catch (e) {
          developer.log('Error adding category ${category.name}: $e', error: e);
        }
      }

      developer.log('Default categories initialization complete!');
      developer.log('Added $addedCount new categories, $skippedCount already existed');

    } catch (e) {
      developer.log('Error initializing default categories: $e', error: e);
      rethrow;
    }
  }

  // Clear all default categories (for testing/reset)
  Future<void> clearDefaultCategories() async {
    try {
      developer.log('Clearing default categories...');

      final categoriesSnapshot = await _firestore
          .collection('categories')
          .where('isCustom', isEqualTo: false)
          .get();

      int deletedCount = 0;
      int protectedCount = 0;
      
      for (final doc in categoriesSnapshot.docs) {
        try {
          // Check if category has recipes
          final recipesSnapshot = await _firestore
              .collection('recipes')
              .where('category', isEqualTo: doc.id)
              .limit(1)
              .get();

          if (recipesSnapshot.docs.isEmpty) {
            await doc.reference.delete();
            deletedCount++;
            developer.log('Deleted category: ${doc['name']}');
          } else {
            protectedCount++;
            developer.log('Cannot delete ${doc['name']} - has ${recipesSnapshot.docs.length} recipes');
          }
        } catch (e) {
          developer.log('Error deleting category ${doc['name']}: $e', error: e);
        }
      }

      developer.log('Cleared $deletedCount default categories, $protectedCount protected due to recipes');
    } catch (e) {
      developer.log('Error clearing default categories: $e', error: e);
      rethrow;
    }
  }

  // Migrate old categories to new format (if needed)
  Future<void> migrateCategories() async {
    try {
      developer.log('Starting categories migration...');

      final categoriesSnapshot = await _firestore.collection('categories').get();

      int migratedCount = 0;
      for (final doc in categoriesSnapshot.docs) {
        try {
          final data = doc.data();

          // Check if category needs migration (missing description or imageUrl field)
          final needsDescription = !data.containsKey('description') || 
                                  data['description'] == null ||
                                  (data['description'] as String).isEmpty;
          
          final needsImageUrl = !data.containsKey('imageUrl') || // Changed from 'icon'
                               data['imageUrl'] == null ||
                               (data['imageUrl'] as String).isEmpty;

          if (needsDescription || needsImageUrl) {
            final categoryName = data['name'] as String;
            final updateData = <String, dynamic>{};

            if (needsDescription) {
              updateData['description'] = _generateDescription(categoryName);
            }

            if (needsImageUrl) {
              updateData['imageUrl'] = _getImageUrlForCategory(categoryName); // Changed method name
            }

            await doc.reference.update(updateData);
            migratedCount++;
            developer.log('Migrated category: $categoryName');
          }
        } catch (e) {
          developer.log('Error migrating category ${doc.id}: $e', error: e);
        }
      }

      if (migratedCount > 0) {
        developer.log('Migration complete! Migrated $migratedCount categories');
      } else {
        developer.log('No migration needed');
      }

    } catch (e) {
      developer.log('Error migrating categories: $e', error: e);
    }
  }

  // Generate description based on category name
  String _generateDescription(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    if (lowerName.contains('breakfast')) {
      return 'Morning meals, smoothies, and energizing recipes to start your day';
    } else if (lowerName.contains('lunch')) {
      return 'Midday meals, salads, and healthy options for your lunch break';
    } else if (lowerName.contains('dinner')) {
      return 'Evening meals, main courses, and family dinners';
    } else if (lowerName.contains('dessert')) {
      return 'Sweet treats, cakes, cookies, and delightful desserts';
    } else if (lowerName.contains('snack')) {
      return 'Quick bites, appetizers, and healthy snacks for any time';
    } else if (lowerName.contains('smoothie')) {
      return 'Healthy drinks, protein shakes, and nutritious smoothies';
    } else if (lowerName.contains('salad')) {
      return 'Fresh, healthy, and colorful salad recipes';
    } else if (lowerName.contains('vegetarian') || lowerName.contains('vegan')) {
      return 'Plant-based, vegetarian, and vegan recipes';
    } else if (lowerName.contains('bakery') || lowerName.contains('bread')) {
      return 'Breads, pastries, muffins, and baked goods';
    } else if (lowerName.contains('asian')) {
      return 'Asian cuisine including Chinese, Japanese, Thai, and Korean recipes';
    } else if (lowerName.contains('italian')) {
      return 'Italian classics: pasta, pizza, risotto, and more';
    } else if (lowerName.contains('mexican')) {
      return 'Mexican favorites: tacos, burritos, guacamole, and more';
    } else if (lowerName.contains('mediterranean')) {
      return 'Healthy Mediterranean diet recipes';
    } else if (lowerName.contains('healthy') || lowerName.contains('diet')) {
      return 'Low-calorie, nutritious, and diet-friendly recipes';
    } else if (lowerName.contains('quick') || lowerName.contains('easy')) {
      return 'Fast recipes that take 30 minutes or less to prepare';
    } else if (lowerName.contains('family') || lowerName.contains('kid')) {
      return 'Kid-friendly recipes loved by the whole family';
    } else if (lowerName.contains('holiday') || lowerName.contains('special')) {
      return 'Recipes perfect for holidays and special occasions';
    } else if (lowerName.contains('drink')) {
      return 'Refreshing beverages, cocktails, and non-alcoholic drinks';
    } else if (lowerName.contains('soup')) {
      return 'Warm and comforting soup recipes for all seasons';
    } else if (lowerName.contains('seafood') || lowerName.contains('fish')) {
      return 'Fish, shrimp, and other seafood recipes';
    } else if (lowerName.contains('appetizer')) {
      return 'Delicious starters and appetizers for parties';
    } else if (lowerName.contains('bbq') || lowerName.contains('grill')) {
      return 'Barbecue and grilled recipes for outdoor cooking';
    } else if (lowerName.contains('comfort')) {
      return 'Comfort food recipes that warm the soul';
    } else if (lowerName.contains('low carb') || lowerName.contains('keto')) {
      return 'Low-carb and keto-friendly recipes';
    } else if (lowerName.contains('gluten free')) {
      return 'Gluten-free recipes for special dietary needs';
    } else if (lowerName.contains('meal prep')) {
      return 'Recipes perfect for meal preparation and planning';
    }
    
    // Default description
    return 'Delicious ${categoryName.toLowerCase()} recipes for every occasion';
  }

  // Get image URL for category
  String _getImageUrlForCategory(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    if (lowerName.contains('breakfast')) {
      return 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400';
    } else if (lowerName.contains('lunch')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    } else if (lowerName.contains('dinner')) {
      return 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400';
    } else if (lowerName.contains('dessert')) {
      return 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400';
    } else if (lowerName.contains('snack')) {
      return 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400';
    } else if (lowerName.contains('smoothie') || lowerName.contains('drink')) {
      return 'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=400';
    } else if (lowerName.contains('salad')) {
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400';
    } else if (lowerName.contains('vegetarian') || lowerName.contains('vegan')) {
      return 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400';
    } else if (lowerName.contains('bakery') || lowerName.contains('bread')) {
      return 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400';
    } else if (lowerName.contains('asian')) {
      return 'https://images.unsplash.com/photo-1563379091339-03246963d9d6?w=400';
    } else if (lowerName.contains('italian')) {
      return 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400';
    } else if (lowerName.contains('mexican')) {
      return 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400';
    } else if (lowerName.contains('mediterranean')) {
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400';
    } else if (lowerName.contains('healthy') || lowerName.contains('diet')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    } else if (lowerName.contains('quick') || lowerName.contains('easy')) {
      return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400';
    } else if (lowerName.contains('family') || lowerName.contains('kid')) {
      return 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400';
    } else if (lowerName.contains('holiday') || lowerName.contains('special')) {
      return 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400';
    } else if (lowerName.contains('drink')) {
      return 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=400';
    } else if (lowerName.contains('soup')) {
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400';
    } else if (lowerName.contains('seafood') || lowerName.contains('fish')) {
      return 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=400';
    } else if (lowerName.contains('appetizer')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    } else if (lowerName.contains('bbq') || lowerName.contains('grill')) {
      return 'https://images.unsplash.com/photo-1558030006-450675393462?w=400';
    } else if (lowerName.contains('comfort')) {
      return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400';
    } else if (lowerName.contains('low carb') || lowerName.contains('keto')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    } else if (lowerName.contains('gluten free')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    } else if (lowerName.contains('meal prep')) {
      return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400';
    }
    
    // Default image
    return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400';
  }

  // Check if initialization is needed
  Future<bool> needsInitialization() async {
    try {
      final categoriesSnapshot = await _firestore
          .collection('categories')
          .where('isCustom', isEqualTo: false)
          .limit(1)
          .get();

      return categoriesSnapshot.docs.isEmpty;
    } catch (e) {
      developer.log('Error checking initialization status: $e', error: e);
      return true; // Assume needs initialization on error
    }
  }

  // Get default category names (for dropdowns, etc.)
  List<String> getDefaultCategoryNames() {
    return _defaultCategories.map((c) => c.name).toList();
  }

  // Get default category by name
  Category? getDefaultCategoryByName(String name) {
    try {
      return _defaultCategories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      developer.log('Default category not found: $name', error: e);
      return null;
    }
  }

  // Get all default categories
  List<Category> getAllDefaultCategories() {
    return List.from(_defaultCategories);
  }

  // Get available image URLs for UI (removed icon-related method)
  List<String> getAvailableImageUrls() {
    return CategoryHelper.getDefaultImageUrls();
  }

  // Initialize default data on app start (call this in main.dart)
  static Future<void> initializeAppData() async {
    try {
      final initializer = DefaultDataInitializer();
      
      // Check if we need initialization
      final needsInit = await initializer.needsInitialization();
      
      if (needsInit) {
        developer.log('Initializing app data for first run...');
        await initializer.initializeDefaultCategories();
        developer.log('App data initialization complete!');
      } else {
        // Run migration if needed
        await initializer.migrateCategories();
        developer.log('App data already initialized, migration complete');
      }
    } catch (e) {
      developer.log('Error in app data initialization: $e', error: e);
      // Don't crash the app, just log the error
    }
  }

  // Get Firestore batch for efficient writes
  Future<void> initializeWithBatch() async {
    try {
      final batch = _firestore.batch();
      final userId = _auth.currentUser?.uid ?? 'system_admin';

      for (final category in _defaultCategories) {
        final docRef = _firestore.collection('categories').doc(category.id);
        
        final categoryData = {
          ...category.copyWith(createdBy: userId, updatedAt: null).toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        batch.set(docRef, categoryData, SetOptions(merge: false));
      }

      await batch.commit();
      developer.log('Batch initialization complete for ${_defaultCategories.length} categories');
    } catch (e) {
      developer.log('Error in batch initialization: $e', error: e);
      rethrow;
    }
  }
}

// Extension for database operations
extension DatabaseOperations on DefaultDataInitializer {
  // Check database connection
  Future<bool> checkDatabaseConnection() async {
    try {
      await _firestore.collection('categories').limit(1).get();
      return true;
    } catch (e) {
      developer.log('Database connection error: $e', error: e);
      return false;
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final categoriesCount = await _firestore
          .collection('categories')
          .count()
          .get()
          .then((snapshot) => snapshot.count);

      final recipesCount = await _firestore
          .collection('recipes')
          .count()
          .get()
          .then((snapshot) => snapshot.count);

      final defaultCategoriesCount = await _firestore
          .collection('categories')
          .where('isCustom', isEqualTo: false)
          .count()
          .get()
          .then((snapshot) => snapshot.count);

      final customCategoriesCount = await _firestore
          .collection('categories')
          .where('isCustom', isEqualTo: true)
          .count()
          .get()
          .then((snapshot) => snapshot.count);

      return {
        'totalCategories': categoriesCount,
        'totalRecipes': recipesCount,
        'defaultCategories': defaultCategoriesCount,
        'customCategories': customCategoriesCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log('Error getting database stats: $e', error: e);
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}