import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recipe.dart';
import '../../core/theme/app_colors.dart';
import '../../data/dummy/dummy_recipes.dart';
import 'widgets/recipe_card.dart';
import 'widgets/add_category_dialog.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Desserts',
    'Bakery',
    'Snacks',
    'Drinks',
  ];
  final List<Recipe> _allRecipes = getDummyRecipes();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _selectedCategoryIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Recipe> _getRecipesByCategory(String category) {
    return _allRecipes.where((recipe) => recipe.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _getRecipesByCategory(_categories[_selectedCategoryIndex]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'TasteFit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddCategoryDialog(),
              ).then((newCategory) {
                if (newCategory != null && newCategory.isNotEmpty) {
                  setState(() {
                    _categories.add(newCategory);
                    _tabController.dispose();
                    _tabController = TabController(
                      length: _categories.length,
                      vsync: this,
                      initialIndex: _selectedCategoryIndex,
                    );
                  });
                }
              });
            },
            tooltip: 'Add New Category',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            isScrollable: true,
            tabs: _categories
                .map(
                  (category) => Tab(
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      body: recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes in ${_categories[_selectedCategoryIndex]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Hero(
                  tag: recipe.id,
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
