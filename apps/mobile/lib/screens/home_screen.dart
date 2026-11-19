import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../services/auth_service.dart';
import '../services/branch_storage_service.dart';
import 'branch_list_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  final Branch selectedBranch;

  const HomeScreen({super.key, required this.selectedBranch});

  // Kullanıcı çıkış yaptığında
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CupClub'),
        actions: [
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
              selectedBranch.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(selectedBranch.address),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MenuScreen(selectedBranch: selectedBranch),
                  ),
                );
              },
              child: const Text('Menüyü Görüntüle'),
            ),
          ],
        ),
      ),
    );
  }
}
