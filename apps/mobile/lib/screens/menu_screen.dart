import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../models/category.dart';
import '../models/branch_product.dart';
import '../models/product_option.dart';
import '../models/product_option_group.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final Branch selectedBranch;
  final CartService cartService;

  const MenuScreen({
    super.key,
    required this.selectedBranch,
    required this.cartService,
  });

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

  void _loadProducts() {
    _productsFuture = _apiService.getBranchProducts(widget.selectedBranch.id);
  }

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

  List<BranchProduct> _getFilteredProducts(List<BranchProduct> products) {
    return products.where((item) {
      if (!item.product.isActive) return false;

      if (_selectedCategoryId == null) return true;

      return item.product.category?.id == _selectedCategoryId;
    }).toList();
  }

  Future<void> _openProductSheet(BranchProduct product) async {
    if (!product.isInStock) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return ProductCustomizationSheet(
          product: product,
          branchId: widget.selectedBranch.id,
          apiService: _apiService,
          cartService: widget.cartService,
        );
      },
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartService: widget.cartService,
          branchId: widget.selectedBranch.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü'),
        actions: [
          ListenableBuilder(
            listenable: widget.cartService,
            builder: (context, child) {
              return IconButton(
                onPressed: _openCart,
                icon: Badge(
                  label: Text('${widget.cartService.totalQuantity}'),
                  isLabelVisible: widget.cartService.totalQuantity > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                tooltip: 'Sepetim',
              );
            },
          ),
        ],
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
                      setState(_loadProducts);
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
                              onTap: item.isInStock
                                  ? () => _openProductSheet(item)
                                  : null,
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

class ProductCustomizationSheet extends StatefulWidget {
  final BranchProduct product;
  final int branchId;
  final ApiService apiService;
  final CartService cartService;

  const ProductCustomizationSheet({
    super.key,
    required this.product,
    required this.branchId,
    required this.apiService,
    required this.cartService,
  });

  @override
  State<ProductCustomizationSheet> createState() =>
      _ProductCustomizationSheetState();
}

class _ProductCustomizationSheetState extends State<ProductCustomizationSheet> {
  late Future<List<ProductOptionGroup>> _optionsFuture;

  final Map<int, Set<int>> _selectedOptions = {};

  int _quantity = 1;

  bool _showSelectionError = false;

  @override
  void initState() {
    super.initState();

    _optionsFuture = widget.apiService.getProductOptions(
      widget.branchId,
      widget.product.productId,
    );
  }

  List<ProductOption> _getSelectedOptions(List<ProductOptionGroup> groups) {
    final result = <ProductOption>[];

    for (final group in groups) {
      final selectedIds = _selectedOptions[group.id] ?? <int>{};

      for (final option in group.options) {
        if (selectedIds.contains(option.id)) {
          result.add(option);
        }
      }
    }

    return result;
  }

  double _calculateTotal(List<ProductOption> options) {
    final extraPrice = options.fold<double>(
      0,
      (total, option) => total + option.additionalPrice,
    );

    return (widget.product.price + extraPrice) * _quantity;
  }

  bool _hasValidSelections(List<ProductOptionGroup> groups) {
    for (final group in groups) {
      final count = _selectedOptions[group.id]?.length ?? 0;

      if (count < group.minSelectable || count > group.maxSelectable) {
        return false;
      }
    }

    return true;
  }

  void _toggleOption(
    ProductOptionGroup group,
    ProductOption option,
    bool selected,
  ) {
    setState(() {
      final selectedIds = _selectedOptions.putIfAbsent(group.id, () => <int>{});

      if (group.maxSelectable == 1) {
        if (group.isRequired) {
          // Zorunlu seçim kaldırılamaz.
          // Başka bir seçenek seçilirse öncekinin yerine geçer.
          selectedIds
            ..clear()
            ..add(option.id);
        } else {
          // İsteğe bağlı seçim tekrar dokunulunca kaldırılır.
          if (selectedIds.contains(option.id)) {
            selectedIds.remove(option.id);
          } else {
            selectedIds
              ..clear()
              ..add(option.id);
          }
        }
      } else {
        if (selected) {
          if (!selectedIds.contains(option.id) &&
              selectedIds.length < group.maxSelectable) {
            selectedIds.add(option.id);
          }
        } else {
          // Çoklu seçimli zorunlu grupta minimum sayı korunur.
          if (!group.isRequired || selectedIds.length > group.minSelectable) {
            selectedIds.remove(option.id);
          }
        }
      }
    });
  }

  void _addToCart(List<ProductOptionGroup> groups) {
    if (!_hasValidSelections(groups)) {
      setState(() {
        _showSelectionError = true;
      });
      return;
    }

    final selectedOptions = _getSelectedOptions(groups);

    final result = widget.cartService.addItem(
      widget.product,
      selectedOptions: selectedOptions,
      quantity: _quantity,
    );

    if (result == CartAddResult.added) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ürün sepete eklenemedi.')));
  }

  Widget _buildGroupTitle(ProductOptionGroup group, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              group.isRequired ? 'Gerekli' : 'İsteğe bağlı',
              style: TextStyle(
                color: group.isRequired
                    ? Colors.red.shade700
                    : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          group.isRequired
              ? 'Bir seçenek belirleyin'
              : 'Dilerseniz seçim yapabilirsiniz',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildOptionGroup(ProductOptionGroup group, BuildContext context) {
    final selectedIds = _selectedOptions[group.id] ?? <int>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        _buildGroupTitle(group, context),
        const SizedBox(height: 8),

        if (group.maxSelectable == 1 && group.isRequired)
          RadioGroup<int>(
            groupValue: selectedIds.isEmpty ? null : selectedIds.first,
            onChanged: (value) {
              if (value != null) {
                final option = group.options.firstWhere(
                  (option) => option.id == value,
                );
                _toggleOption(group, option, true);
              }
            },
            child: Column(
              children: group.options.map((option) {
                return RadioListTile<int>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${option.name} '
                    '(+${option.additionalPrice.toStringAsFixed(2)} TL)',
                  ),
                  value: option.id,
                  selected: selectedIds.contains(option.id),
                );
              }).toList(),
            ),
          )
        else
          ...group.options.map((option) {
            final isSelected = selectedIds.contains(option.id);

            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${option.name} '
                '(+${option.additionalPrice.toStringAsFixed(2)} TL)',
              ),
              value: isSelected,
              onChanged: (value) {
                _toggleOption(group, option, value ?? false);
              },
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductOptionGroup>>(
      future: _optionsFuture,
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];

        final selectedOptions = _getSelectedOptions(groups);

        final total = _calculateTotal(selectedOptions);

        final hasValidSelections = _hasValidSelections(groups);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.product.product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.product.price.toStringAsFixed(2)} TL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Ürün seçenekleri yüklenemedi.'),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _optionsFuture = widget.apiService
                                    .getProductOptions(
                                      widget.branchId,
                                      widget.product.productId,
                                    );
                              });
                            },
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: groups.map((group) {
                        return _buildOptionGroup(group, context);
                      }).toList(),
                    ),
                  ),

                const Divider(),

                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    Text(
                      '${total.toStringAsFixed(2)} TL',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                if (_showSelectionError && !hasValidSelections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lütfen seçim yapınız.',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        snapshot.hasError ||
                            snapshot.connectionState == ConnectionState.waiting
                        ? null
                        : () => _addToCart(groups),
                    child: const Text('Sepete Ekle'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
