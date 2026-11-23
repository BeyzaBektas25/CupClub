class ProductOption {
  final int id;
  final String name;
  final double additionalPrice;

  ProductOption({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'],
      name: json['name'],
      additionalPrice: double.parse(json['additional_price'].toString()),
    );
  }
}
