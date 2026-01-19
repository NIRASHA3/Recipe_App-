/// Shopping List Domain Model
///
/// Represents an item in the shopping list with:
/// - Quantity (integer for whole numbers only)
/// - Unit of measurement
/// - Purchase status tracking
///
class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String category;
  bool isPurchased;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isPurchased = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? category,
    bool? isPurchased,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isPurchased': isPurchased,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unit: map['unit'] as String,
      category: map['category'] as String,
      isPurchased: map['isPurchased'] as bool,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, unit: $unit, category: $category, isPurchased: $isPurchased)';
  }
}
