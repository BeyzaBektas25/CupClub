import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../models/category.dart';
import '../models/branch_product.dart';
import '../services/api_service.dart';

class MenuScreen extends StatefulWidget {
  final Branch selectedBranch;

  const MenuScreen({super.key, required this.selectedBranch});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<BranchProduct>> _productsFuture;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Seçili şubenin ürünlerini getirir
  void _loadProducts() {
    _productsFuture = _apiService.getBranchProducts(widget.selectedBranch.id);
  }

  // Ürünlerden kategorileri oluşturur
  List<Category> _getCategories(List<BranchProduct> products) {
    final Map<int, Category> categories = {};

    for (final item in products) {
      final category = item.product.category;

      if (category != null && item.product.isActive) {
        categories[category.id] = category;
      }
    }

    final result = categories.values.toList();

    result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return result;
  }

  // Seçilen kategoriye göre ürünleri filtreler
  List<BranchProduct> _getFilteredProducts(List<BranchProduct> products) {
    return products.where((item) {
      if (!item.product.isActive) {
        return false;
      }

      if (_selectedCategoryId == null) {
        return true;
      }

      return item.product.category?.id == _selectedCategoryId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.selectedBranch.name,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<BranchProduct>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Menü yüklenemedi.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadProducts();
                      });
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('Bu şubede henüz ürün bulunmuyor.'),
            );
          }

          final categories = _getCategories(products);
          final filteredProducts = _getFilteredProducts(products);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori listesi
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    ChoiceChip(
                      label: const Text('Tümü'),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Ürün listesi
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text('Bu kategoride ürün bulunamadı.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          final product = item.product;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.description != null)
                                    Text(product.description!),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.isInStock ? 'Stokta' : 'Tükendi',
                                    style: TextStyle(
                                      color: item.isInStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${item.price.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
