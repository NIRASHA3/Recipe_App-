// lib/data/providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository.dart';
import '../../domain/models/category.dart';

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// All categories provider
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getAllCategories();
});

// Default categories provider
final defaultCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getDefaultCategories();
});

// Custom categories provider
final customCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCustomCategories();
});

// Single category provider
final categoryProvider = StreamProvider.family<Category?, String>((
  ref,
  categoryId,
) async* {
  final repository = ref.read(categoryRepositoryProvider);
  final category = await repository.getCategoryById(categoryId);
  if (category != null) {
    yield category;
  }
});

// Search categories provider
final searchCategoriesProvider = StreamProvider.family<List<Category>, String>((
  ref,
  query,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.searchCategories(query);
});

// Popular categories provider
final popularCategoriesProvider = StreamProvider.family<List<Category>, int>((
  ref,
  limit,
) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getPopularCategories(limit: limit);
});

// Category CRUD operations provider
final categoryActionsProvider = Provider<CategoryActions>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryActions(repository);
});

// Category actions service class
class CategoryActions {
  final CategoryRepository _repository;

  CategoryActions(this._repository);

  Future<Category> createCategory(
    String name,
    String description,
    String imageUrl, {
    bool isCustom = true,
  }) async {
    final category = Category(
      name: name,
      description: description,
      imageUrl: imageUrl,
      recipeCount: 0,
      isCustom: isCustom,
      createdAt: DateTime.now(),
    );
    return _repository.createCategory(category);
  }

  Future<Category> updateCategory(
    String categoryId,
    String name,
    String description,
    String imageUrl,
  ) async {
    final existingCategory = await _repository.getCategoryById(categoryId);
    if (existingCategory == null) {
      throw Exception('Category not found');
    }

    final updatedCategory = existingCategory.copyWith(
      name: name,
      description: description,
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    return _repository.updateCategory(updatedCategory);
  }

  Future<void> deleteCategory(String categoryId) async {
    return _repository.deleteCategory(categoryId);
  }

  Future<int?> getCategoryCount() async {
    return _repository.getCategoriesCount();
  }

  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    return _repository.categoryNameExists(name, excludeId: excludeId);
  }
}
