import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/logged_meal.dart';
import '../../data/providers/recipe_provider.dart';

class NutritionTrackerScreen extends ConsumerStatefulWidget {
  const NutritionTrackerScreen({super.key});

  @override
  ConsumerState<NutritionTrackerScreen> createState() =>
      _NutritionTrackerScreenState();
}

class _NutritionTrackerScreenState
    extends ConsumerState<NutritionTrackerScreen> {
  DateTime selectedDate = DateTime.now();
  final dailyGoals = const {
    'calories': 1850.0,
    'protein': 198.0,
    'carbs': 250.0,
    'fats': 122.0,
    'fiber': 30.0,
  };

  Map<String, double> _calculateTotals(List<LoggedMeal> meals) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    double fiber = 0;
    for (final meal in meals) {
      calories += meal.totalCalories;
      protein += meal.totalProtein;
      carbs += meal.totalCarbs;
      fats += meal.totalFats;
      fiber += (meal.recipe.nutrition.fiber ?? 0) * meal.servings;
    }
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
    };
  }

  double _calculatePercentage(double current, double goal) {
    if (goal == 0) return 0;
    return (current / goal).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final mealLogger = ref.watch(mealLoggerProvider);
    final todaysMeals = mealLogger
        .where(
          (meal) =>
              meal.dateOnly ==
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        )
        .toList();
    final totals = _calculateTotals(todaysMeals);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () {
              // Sync action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Synced with device!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector (matches image: clean row with arrow)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Calories Card (circular progress, matches image: green theme with gradient)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      // ignore: deprecated_member_use
                      const Color.fromARGB(255, 103, 96, 83).withOpacity(0.8),
                      const Color.fromARGB(255, 172, 120, 36),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icon + Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: const Color.fromARGB(
                              255,
                              156,
                              149,
                              149,
                            // ignore: deprecated_member_use
                            ).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Color.fromARGB(255, 156, 149, 149),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Daily Calories',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Consumed vs Goal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${totals['calories']!.toInt()}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Consumed',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 2, height: 70, color: Colors.white30),
                        Column(
                          children: [
                            Text(
                              '${dailyGoals['calories']!.toInt()}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Goal',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Circular Progress
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: _calculatePercentage(
                              totals['calories']!,
                              dailyGoals['calories']!,
                            ),
                            strokeWidth: 8,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(_calculatePercentage(totals['calories']!, dailyGoals['calories']!) * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'of goal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Macronutrients Section (grid with icons, bars, matches image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Macronutrients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 81, 77, 77),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _MacroCard(
                  name: 'Protein',
                  current: totals['protein']!,
                  goal: dailyGoals['protein']!,
                  color: Colors.red,
                  unit: 'g',
                  icon: Icons.fitness_center,
                ),
                _MacroCard(
                  name: 'Carbs',
                  current: totals['carbs']!,
                  goal: dailyGoals['carbs']!,
                  color: Colors.blue,
                  unit: 'g',
                  icon: Icons.grain,
                ),
                _MacroCard(
                  name: 'Fats',
                  current: totals['fats']!,
                  goal: dailyGoals['fats']!,
                  color: Colors.green,
                  unit: 'g',
                  icon: Icons.opacity,
                ),
                _MacroCard(
                  name: 'Fiber',
                  current: totals['fiber']!,
                  goal: dailyGoals['fiber']!,
                  color: Colors.purple,
                  unit: 'g',
                  icon: Icons.grass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Logged Meals (swipe delete, matches image style)
            Text(
              'Meals Logged (${todaysMeals.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            todaysMeals.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No meals logged yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todaysMeals.length,
                    itemBuilder: (context, index) {
                      final meal = todaysMeals[index];
                      return Dismissible(
                        key: Key(meal.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(mealLoggerProvider.notifier)
                              .removeMeal(meal.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${meal.recipe.title} removed'),
                              // ignore: deprecated_member_use
                              backgroundColor: Colors.red.withOpacity(0.8),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              meal.recipe.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color.fromARGB(255, 235, 230, 230),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'} • ${meal.loggedAt.toString().split(' ')[1].substring(0, 5)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${meal.totalCalories.toInt()} kcal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        'P:${meal.totalProtein.toInt()}g C:${meal.totalCarbs.toInt()}g',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => ref
                                        .read(mealLoggerProvider.notifier)
                                        .removeMeal(meal.id),
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            // Insights Section (cards with gradients, matches image)
            Text(
              'Daily Insights',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _InsightCard(
              title: todaysMeals.isEmpty ? 'Start Logging 📝' : 'Great Job! 🎉',
              description: todaysMeals.isEmpty
                  ? 'Log your meals to track your nutrition and reach your fitness goals!'
                  : 'You are ${(_calculatePercentage(totals['calories']!, dailyGoals['calories']!) * 100).toStringAsFixed(0)}% of your daily calorie goal. Keep up the healthy eating!',
              // ignore: deprecated_member_use
              backgroundColor: todaysMeals.isEmpty
                  // ignore: deprecated_member_use
                  ? Colors.blue.withOpacity(0.1)
                  // ignore: deprecated_member_use
                  : AppColors.success.withOpacity(0.1),
              borderColor: todaysMeals.isEmpty
                  ? Colors.blue
                  : AppColors.success,
            ),
            const SizedBox(height: 12),
            _InsightCard(
              title: 'Protein Intake',
              description:
                  'You have consumed ${totals['protein']!.toInt()}g of protein. Your goal is ${dailyGoals['protein']!.toInt()}g.',
              // ignore: deprecated_member_use
              backgroundColor: Colors.red.withOpacity(0.1),
              borderColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String name;
  final double current;
  final double goal;
  final Color color;
  final String unit;
  final IconData? icon;

  const _MacroCard({
    required this.name,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (current / goal).clamp(0.0, 1.0);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, size: 16, color: color),
                      ),
                    if (icon != null) const SizedBox(width: 6),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 4,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${current.toInt()}$unit / ${goal.toInt()}$unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _LoggedMealTile extends StatelessWidget {
  final LoggedMeal meal;
  final VoidCallback onDelete;

  const _LoggedMealTile({required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(meal.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => onDelete(),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_menu, color: AppColors.primary),
          ),
          title: Text(
            meal.recipe.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'} • ${meal.loggedAt.toString().split(' ')[1].substring(0, 5)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${meal.totalCalories.toInt()} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'P:${meal.totalProtein.toInt()}g C:${meal.totalCarbs.toInt()}g',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color borderColor;

  const _InsightCard({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              // ignore: deprecated_member_use
              color: borderColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
