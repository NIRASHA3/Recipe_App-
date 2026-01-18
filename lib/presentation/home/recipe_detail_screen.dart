import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/logged_meal.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late List<bool> _ingredientChecked;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _ingredientChecked = List.filled(widget.recipe.ingredients.length, false);

    // Animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showServingsDialog(BuildContext context, WidgetRef ref) {
    int servings = widget.recipe.servings;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Log Meal: ${widget.recipe.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select number of servings:',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (servings > 1) servings--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        iconSize: 32,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$servings',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            servings++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Calories:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${(widget.recipe.nutrition.calories * servings).toInt()} kcal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Protein:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${(widget.recipe.nutrition.protein * servings).toStringAsFixed(1)}g',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Log the meal using read with proper context
                          final loggedMeal = LoggedMeal(
                            recipe: widget.recipe,
                            servings: servings,
                            loggedAt: DateTime.now(),
                          );
                          ref
                              .read(mealLoggerProvider.notifier)
                              .addMeal(loggedMeal);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.recipe.title} ($servings servings) logged to nutrition tracker',
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Log Meal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addIngredientsToShoppingList(WidgetRef ref) {
    for (final ingredient in widget.recipe.ingredients) {
      ref
          .read(shoppingListProvider.notifier)
          .addItem(
            ShoppingItem(
              id: ingredient.id,
              name: ingredient.name,
              quantity: ingredient.quantity,
              unit: ingredient.unit,
              category: widget.recipe.category,
            ),
          );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.recipe.ingredients.length} ingredients added to shopping list',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    // Check if recipe is in favorites using the provider
    final favoriteIds = ref.watch(favoritesProvider);
    final isFavoritedFromProvider = favoriteIds.contains(recipe.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeController.drive(Tween(begin: 0.0, end: 1.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prominent image section with overlay
              SlideTransition(
                position: _slideController.drive(
                  Tween(begin: const Offset(0, -0.3), end: Offset.zero),
                ),
                child: Stack(
                  children: [
                    // Image background
                    Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: recipe.imageUrl != null
                          ? Image.network(
                              recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 100,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.restaurant,
                                size: 100,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                    // Gradient overlay
                    Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Top app bar area
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.textDark,
                                    size: 20,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Toggle favorite in provider
                                  if (isFavoritedFromProvider) {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .removeFavorite(recipe.id);
                                  } else {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .addFavorite(recipe.id);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            isFavoritedFromProvider
                                                ? Icons.favorite_border
                                                : Icons.favorite,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isFavoritedFromProvider
                                                ? 'Removed from favorites'
                                                : 'Added to favorites',
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      backgroundColor: isFavoritedFromProvider
                                          ? Colors.grey
                                          : Colors.red,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isFavoritedFromProvider
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavoritedFromProvider
                                        ? Colors.red
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Recipe title overlay at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: ScaleTransition(
                        scale: _scaleController.drive(
                          Tween(begin: 0.8, end: 1.0),
                        ),
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Key details section with prominent row
              Padding(
                padding: const EdgeInsets.all(16),
                child: ScaleTransition(
                  scale: _scaleController.drive(Tween(begin: 0.9, end: 1.0)),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Key details row - Circular badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _CircularDetailBadge(
                                icon: Icons.access_time,
                                label: 'prep',
                                value: '${recipe.prepTimeMinutes}',
                                color: Colors.blue,
                              ),
                              _CircularDetailBadge(
                                icon: Icons.people,
                                label: 'servings',
                                value: '${recipe.servings}',
                                color: Colors.green,
                              ),
                              _CircularDetailBadge(
                                icon: Icons.local_fire_department,
                                label: 'Cal',
                                value: '${recipe.nutrition.calories.toInt()}',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rating section - Professional badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  recipe.rating?.toStringAsFixed(1) ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber[900],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.amber[700],
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
              ),

              // Ingredients section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: List.generate(recipe.ingredients.length, (
                        index,
                      ) {
                        final ingredient = recipe.ingredients[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _ingredientChecked[index]
                                // ignore: deprecated_member_use
                                ? Colors.green.withOpacity(0.1)
                                // ignore: deprecated_member_use
                                : AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _ingredientChecked[index]
                                  ? AppColors.success
                                  // ignore: deprecated_member_use
                                  : AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _ingredientChecked[index],
                                onChanged: (value) {
                                  setState(() {
                                    _ingredientChecked[index] = value ?? false;
                                  });
                                },
                                activeColor: AppColors.success,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: _ingredientChecked[index]
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: _ingredientChecked[index]
                                        ? Colors.grey
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 22,
                                ),
                                color: AppColors.primary,
                                onPressed: () {
                                  ref
                                      .read(shoppingListProvider.notifier)
                                      .addItem(
                                        ShoppingItem(
                                          id: ingredient.id,
                                          name: ingredient.name,
                                          quantity: ingredient.quantity,
                                          unit: ingredient.unit,
                                          category: recipe.category,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${ingredient.name} added to shopping list',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                tooltip: 'Add to shopping list',
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Instructions section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Directions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(recipe.instructions.length, (
                        index,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      // ignore: deprecated_member_use
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Step ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      recipe.instructions[index],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.8,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Nutrition section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Nutrition Facts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _NutritionRow(
                          label: 'Calories',
                          value: '${recipe.nutrition.calories.toInt()}',
                          unit: 'kcal',
                          color: Colors.orange,
                          icon: Icons.local_fire_department,
                        ),
                        const Divider(height: 20, thickness: 1.5),
                        _NutritionRow(
                          label: 'Protein',
                          value: recipe.nutrition.protein.toStringAsFixed(1),
                          unit: 'g',
                          color: Colors.red,
                          icon: Icons.fitness_center,
                        ),
                        const Divider(height: 20, thickness: 1.5),
                        _NutritionRow(
                          label: 'Carbohydrates',
                          value: recipe.nutrition.carbs.toStringAsFixed(1),
                          unit: 'g',
                          color: Colors.blue,
                          icon: Icons.grain,
                        ),
                        const Divider(height: 20, thickness: 1.5),
                        _NutritionRow(
                          label: 'Fats',
                          value: recipe.nutrition.fats.toStringAsFixed(1),
                          unit: 'g',
                          color: Colors.green,
                          icon: Icons.opacity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showServingsDialog(context, ref),
                        icon: const Icon(Icons.restaurant_menu, size: 22),
                        label: const Text(
                          'Log This Meal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _addIngredientsToShoppingList(ref),
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 22,
                        ),
                        label: const Text(
                          'Add All to Shopping List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Circular badge widget for detail display
class _CircularDetailBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CircularDetailBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 60, color: Colors.grey[300]);
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData? icon;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon ?? Icons.info_outline, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
