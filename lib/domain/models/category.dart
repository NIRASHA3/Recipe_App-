import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String icon; // Icon name or emoji
  final bool isCustom;

  Category({
    String? id,
    required this.name,
    required this.icon,
    this.isCustom = false,
  }) : id = id ?? const Uuid().v4();

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String?,
      name: json['name'] as String,
      icon: json['icon'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon, 'isCustom': isCustom};
  }

  Category copyWith({String? id, String? name, String? icon, bool? isCustom}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  String toString() => name;
}

// Default categories
final defaultCategories = [
  Category(name: 'Breakfast', icon: '🍳'),
  Category(name: 'Lunch', icon: '🍲'),
  Category(name: 'Dinner', icon: '🍽️'),
  Category(name: 'Desserts', icon: '🍰'),
  Category(name: 'Bakery', icon: '🥐'),
  Category(name: 'Snacks', icon: '🥜'),
  Category(name: 'Drinks', icon: '🥤'),
];
