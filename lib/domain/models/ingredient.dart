import 'package:uuid/uuid.dart';

class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  bool isChecked;

  Ingredient({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String?,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  String toString() => '$quantity $unit $name';
}