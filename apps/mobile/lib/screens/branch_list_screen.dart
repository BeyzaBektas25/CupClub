import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../services/api_service.dart';
import '../services/branch_storage_service.dart';
import 'home_screen.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final ApiService _apiService = ApiService();
  final BranchStorageService _branchStorage = BranchStorageService();

  late Future<List<Branch>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = _apiService.getBranches();
  }

  void _loadBranches() {
    setState(() {
      _branchesFuture = _apiService.getBranches();
    });
  }

  Future<void> _selectBranch(Branch branch) async {
    await _branchStorage.saveBranchId(branch.id);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(selectedBranch: branch),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şubelerimiz')),
      body: FutureBuilder<List<Branch>>(
        future: _branchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Şubeler yüklenemedi.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadBranches,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final branches = snapshot.data ?? [];

          if (branches.isEmpty) {
            return const Center(child: Text('Henüz aktif şube bulunmuyor.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(branch.name),
                  subtitle: Text(
                    '${branch.address}\n'
                    'Çalışma saatleri: ${branch.workingHours}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectBranch(branch),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
