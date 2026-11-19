import 'category.dart';

class Product {
  final int id;
  final String name;
  final Category? category;
  final String? description;
  final String? imageUrl;
  final String? allergens;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    this.allergens,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      description: json['description'],
      imageUrl: json['image_url'],
      allergens: json['allergens'],
      isActive: json['is_active'],
    );
  }
}
