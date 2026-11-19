import 'product_option.dart';

class ProductOptionGroup {
  final int id;
  final String name;
  final bool isRequired;
  final int minSelectable;
  final int maxSelectable;
  final List<ProductOption> options;

  ProductOptionGroup({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.minSelectable,
    required this.maxSelectable,
    required this.options,
  });

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      id: json['id'],
      name: json['name'],
      isRequired: json['is_required'] ?? false,
      minSelectable: json['min_selectable'] ?? 0,
      maxSelectable: json['max_selectable'] ?? 1,
      options: (json['options'] as List<dynamic>? ?? [])
          .map(
            (option) =>
                ProductOption.fromJson(Map<String, dynamic>.from(option)),
          )
          .toList(),
    );
  }
}
