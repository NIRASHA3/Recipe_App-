import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/recipe_provider.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingItems = ref.watch(shoppingListProvider);

    // Group items by category
    final groupedItems = <String, List<ShoppingItem>>{};
    for (var item in shoppingItems) {
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = [];
      }
      groupedItems[item.category]!.add(item);
    }

    final purchasedCount = shoppingItems.where((i) => i.isPurchased).length;
    final unPurchasedCount = shoppingItems.where((i) => !i.isPurchased).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        actions: [
          if (purchasedCount > 0)
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'clear') {
                  ref.read(shoppingListProvider.notifier).clearPurchased();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Purchased items cleared'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear Purchased'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: shoppingItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Shopping list is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add ingredients from your favorite recipes',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress card with animation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            AppColors.primary.withOpacity(0.05),
                            // ignore: deprecated_member_use
                            AppColors.primary.withOpacity(0.02),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shopping Progress',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$purchasedCount / ${shoppingItems.length} items',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${((purchasedCount / shoppingItems.length) * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: purchasedCount / shoppingItems.length,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Shopping items list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (unPurchasedCount > 0)
                        _ShoppingCategorySection(
                          category: 'To Buy',
                          items: shoppingItems
                              .where((i) => !i.isPurchased)
                              .toList(),
                          isPurchasedSection: false,
                        ),
                      if (purchasedCount > 0)
                        _ShoppingCategorySection(
                          category: 'Completed',
                          items: shoppingItems
                              .where((i) => i.isPurchased)
                              .toList(),
                          isPurchasedSection: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ShoppingCategorySection extends ConsumerWidget {
  final String category;
  final List<ShoppingItem> items;
  final bool isPurchasedSection;

  const _ShoppingCategorySection({
    required this.category,
    required this.items,
    this.isPurchasedSection = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Row(
            children: [
              Icon(
                isPurchasedSection ? Icons.check_circle : Icons.shopping_bag,
                color: isPurchasedSection
                    ? AppColors.success
                    : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isPurchasedSection
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (isPurchasedSection
                              ? AppColors.success
                              : AppColors.primary)
                          // ignore: deprecated_member_use
                          .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPurchasedSection
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPurchasedSection
                  // ignore: deprecated_member_use
                  ? AppColors.success.withOpacity(0.2)
                  // ignore: deprecated_member_use
                  : AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return _ShoppingItemTile(
                item: item,
                isPurchasedSection: isPurchasedSection,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ShoppingItemTile extends ConsumerStatefulWidget {
  final ShoppingItem item;
  final bool isPurchasedSection;

  const _ShoppingItemTile({
    required this.item,
    this.isPurchasedSection = false,
  });

  @override
  ConsumerState<_ShoppingItemTile> createState() => _ShoppingItemTileState();
}

class _ShoppingItemTileState extends ConsumerState<_ShoppingItemTile> {
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  void _showEditDialog(BuildContext context) {
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
                    'Edit ${widget.item.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quantity:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_quantity > 0.5) _quantity -= 0.5;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        iconSize: 28,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _quantity.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity += 0.5;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${widget.item.name}: $_quantity ${widget.item.unit}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
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
                          // Update item quantity in the provider
                          ref
                              .read(shoppingListProvider.notifier)
                              .updateItem(widget.item.id, _quantity);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Updated ${widget.item.name} to $_quantity ${widget.item.unit}',
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.id),
      background: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        ref.read(shoppingListProvider.notifier).removeItem(widget.item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.item.name} removed from shopping list'),
            duration: const Duration(seconds: 1),
            // ignore: deprecated_member_use
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: CheckboxListTile(
          value: widget.item.isPurchased,
          onChanged: (value) {
            ref
                .read(shoppingListProvider.notifier)
                .togglePurchased(widget.item.id);
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: widget.item.isPurchased
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: widget.item.isPurchased
                      ? Colors.grey[400]
                      : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.item.quantity} ${widget.item.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.item.isPurchased
                      ? Colors.grey[300]
                      : Colors.white54,
                ),
              ),
            ],
          ),
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primary,
                iconSize: 20,
                onPressed: () => _showEditDialog(context),
                tooltip: 'Edit quantity',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                iconSize: 20,
                onPressed: () {
                  ref
                      .read(shoppingListProvider.notifier)
                      .removeItem(widget.item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.item.name} removed'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                tooltip: 'Delete item',
              ),
            ],
          ),
          activeColor: AppColors.success,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
