import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/shopping_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/network_image_widget.dart';
import '../../data/providers/shopping_list_provider.dart';
import '../../data/providers/meal_logger_provider.dart';
import '../../data/providers/favorites_provider.dart';
import '../../data/providers/recipe_provider.dart';
import 'edit_recipe_dialog.dart';

// Provider to watch a specific recipe in real-time
final recipeStreamProvider = StreamProvider.family<Recipe?, String>((
  ref,
  recipeId,
) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.watchRecipe(recipeId);
});

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late List<bool> _ingredientChecked;
  int _servings = 1;
  double _userRating = 0;
  DateTime? _lastRatingTap;

  @override
  void initState() {
    super.initState();
    _ingredientChecked = List.filled(widget.recipe.ingredients.length, false);
    _servings = widget.recipe.servings;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the recipe for real-time updates
    final recipeAsync = ref.watch(recipeStreamProvider(widget.recipe.id));

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Not Found')),
            body: const Center(child: Text('This recipe has been deleted')),
          );
        }

        // Update ingredient checked list if ingredients changed
        if (_ingredientChecked.length != recipe.ingredients.length) {
          _ingredientChecked = List.filled(recipe.ingredients.length, false);
        }

        return _buildRecipeContent(recipe);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(widget.recipe.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildRecipeContent(Recipe recipe) {
    final favoriteIdsAsync = ref.watch(favoritesProvider);
    final isFavorite = favoriteIdsAsync.maybeWhen(
      data: (ids) => ids.contains(recipe.id),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Edit Button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditRecipeDialog(recipe: recipe),
                  );
                },
              ),
              // Favorite Button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await ref
                        .read(favoritesActionsProvider)
                        .removeFavorite(recipe.id);
                  } else {
                    await ref
                        .read(favoritesActionsProvider)
                        .addFavorite(recipe.id);
                  }
                },
              ),
              // Delete Button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Delete Recipe'),
                      content: Text(
                        'Are you sure you want to delete "${recipe.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await ref
                                  .read(recipeActionsProvider)
                                  .deleteRecipe(recipe.id);
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${recipe.title} deleted successfully',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Recipe Image
                  recipe.imageUrl != null
                      ? SimpleNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                // ignore: deprecated_member_use
                                AppColors.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content on curved white surface
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Card(
                        elevation: 10,
                        color: Colors.white,
                        // ignore: deprecated_member_use
                        shadowColor: Colors.black.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                recipe.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Rating Section
                              _buildRatingSection(recipe),
                              const SizedBox(height: 16),
                              // Quick Info Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildInfoChip(
                                    icon: Icons.schedule,
                                    label:
                                        '${recipe.prepTime + recipe.cookTime} min',
                                    color: Colors.blue,
                                  ),
                                  _buildInfoChip(
                                    icon: Icons.restaurant,
                                    label: '${recipe.servings} servings',
                                    color: Colors.green,
                                  ),
                                  _buildInfoChip(
                                    icon: Icons.signal_cellular_alt,
                                    label: recipe.difficulty.name,
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Nutrition Info - Modern Card Design
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nutrition Facts',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Per serving',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Nutrition Grid - Horizontal Layout
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Calories',
                                      value:
                                          '${recipe.nutrition.calories.toInt()}',
                                      unit: 'kcal',
                                      color: Colors.orange,
                                      icon: Icons.local_fire_department,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Protein',
                                      value: recipe.nutrition.protein
                                          .toStringAsFixed(1),
                                      unit: 'g',
                                      color: Colors.red,
                                      icon: Icons.fitness_center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Carbs',
                                      value: recipe.nutrition.carbs
                                          .toStringAsFixed(1),
                                      unit: 'g',
                                      color: Colors.blue,
                                      icon: Icons.grain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Fats',
                                      value: recipe.nutrition.fats
                                          .toStringAsFixed(1),
                                      unit: 'g',
                                      color: Colors.green,
                                      icon: Icons.opacity,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Fiber',
                                      value: recipe.nutrition.fiber
                                          .toStringAsFixed(1),
                                      unit: 'g',
                                      color: Colors.brown,
                                      icon: Icons.eco,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNutritionCard(
                                      label: 'Sugar',
                                      value: recipe.nutrition.sugar
                                          .toStringAsFixed(1),
                                      unit: 'g',
                                      color: Colors.pink,
                                      icon: Icons.cake,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Ingredients Section (match Instructions styling)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${recipe.ingredients.length} items',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...recipe.ingredients.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final ingredient = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _ingredientChecked[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _ingredientChecked[index] =
                                                value ?? false;
                                          });
                                        },
                                        activeColor: AppColors.primary,
                                        checkColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${ingredient.quantity} ${ingredient.unit ?? ''} ${ingredient.name}'
                                              .trim(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            decoration:
                                                _ingredientChecked[index]
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 20,
                                        ),
                                        color: Colors.grey[600],
                                        onPressed: () async {
                                          await ref
                                              .read(shoppingListActionsProvider)
                                              .addItem(
                                                ShoppingItem(
                                                  id: DateTime.now()
                                                      .millisecondsSinceEpoch
                                                      .toString(),
                                                  name: ingredient.name,
                                                  quantity: ingredient.quantity,
                                                  unit: ingredient.unit ?? '',
                                                  category: recipe.categoryId,
                                                ),
                                              );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${ingredient.name} added to shopping list',
                                                ),
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Instructions Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...recipe.instructions.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final instruction = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              // ignore: deprecated_member_use
                                              AppColors.primary.withOpacity(
                                                0.7,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          instruction,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[600],
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showLogMealDialog(recipe),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.restaurant_menu),
                              label: const Text(
                                'Log Meal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                for (var ingredient in recipe.ingredients) {
                                  await ref
                                      .read(shoppingListActionsProvider)
                                      .addItem(
                                        ShoppingItem(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          name: ingredient.name,
                                          quantity: ingredient.quantity,
                                          unit: ingredient.unit ?? '',
                                          category: recipe.categoryId,
                                        ),
                                      );
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'All ingredients added to shopping list',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text(
                                'Add All',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rate this recipe:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final isDoubleClick =
                        _lastRatingTap != null &&
                        now.difference(_lastRatingTap!).inMilliseconds < 300 &&
                        _userRating == index + 1.0;

                    setState(() {
                      _lastRatingTap = now;
                      if (isDoubleClick) {
                        // Double-click: toggle off the rating
                        _userRating = 0;
                      } else {
                        // Single click: set the rating
                        _userRating = index + 1.0;
                      }
                    });

                    // Save rating to Firestore
                    try {
                      if (_userRating > 0) {
                        final updatedRecipe = recipe.copyWith(
                          rating: _userRating,
                        );
                        await ref
                            .read(recipeActionsProvider)
                            .updateRecipe(updatedRecipe);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Rated ${_userRating.toInt()} stars',
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // Clear rating
                        final updatedRecipe = recipe.copyWith(rating: null);
                        await ref
                            .read(recipeActionsProvider)
                            .updateRecipe(updatedRecipe);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rating removed'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving rating: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                );
              }),
            ),
          ],
        ),
        if (recipe.rating != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                recipe.rating!.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                ' / 5.0',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showLogMealDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many servings of ${recipe.title}?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_servings > 1) {
                      setState(() => _servings--);
                      Navigator.pop(context);
                      _showLogMealDialog(recipe);
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_servings',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _servings++);
                    Navigator.pop(context);
                    _showLogMealDialog(recipe);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(mealLoggerActionsProvider)
                    .logMeal(recipe, _servings);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal logged successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Meal'),
          ),
        ],
      ),
    );
  }
}
