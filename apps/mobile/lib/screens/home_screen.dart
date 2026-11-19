import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../services/auth_service.dart';
import '../services/branch_storage_service.dart';
import '../services/cart_service.dart';
import 'branch_list_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  final Branch selectedBranch;

  const HomeScreen({super.key, required this.selectedBranch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _cartService.setBranch(widget.selectedBranch.id);
  }

  @override
  void dispose() {
    _cartService.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    final branchStorage = BranchStorageService();

    await authService.logout();
    await branchStorage.clearBranchId();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          selectedBranch: widget.selectedBranch,
          cartService: _cartService,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartService: _cartService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CupClub'),
        actions: [
          ListenableBuilder(
            listenable: _cartService,
            builder: (context, child) {
              return IconButton(
                onPressed: _openCart,
                icon: Badge(
                  label: Text('${_cartService.totalQuantity}'),
                  isLabelVisible: _cartService.totalQuantity > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                tooltip: 'Sepetim',
              );
            },
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 40),
            const SizedBox(height: 12),
            const Text('Seçili şubeniz:'),
            const SizedBox(height: 8),
            Text(
              widget.selectedBranch.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.selectedBranch.address),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BranchListScreen(),
                  ),
                );
              },
              child: const Text('Şubeyi Değiştir'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openMenu,
              child: const Text('Menüyü Görüntüle'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Sepetim'),
            ),
          ],
        ),
      ),
    );
  }
}
