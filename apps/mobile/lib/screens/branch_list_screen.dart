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

  static const Color cream = Color(0xFFFCF5E9);
  static const Color brown = Color(0xFF7A4A2F);
  static const Color darkBrown = Color(0xFF4A2B1C);
  static const Color cinnamon = Color(0xFFB9784F);

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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CupClub',
          style: TextStyle(
            color: brown,
            fontSize: 27,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Şubelerimiz',
          style: TextStyle(
            color: darkBrown,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Sipariş vermek istediğin şubeyi seç.',
          style: TextStyle(color: Color(0xFF8A6A55), fontSize: 14),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: cinnamon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF806957),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.name,
            style: const TextStyle(
              color: darkBrown,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _buildInfoRow(icon: Icons.location_on_outlined, text: branch.address),

          const SizedBox(height: 11),

          _buildInfoRow(
            icon: Icons.access_time_rounded,
            text: 'Çalışma saatleri: ${branch.workingHours}',
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _selectBranch(branch),
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bu şubeyi seç',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: brown));
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: cinnamon),
            const SizedBox(height: 14),
            const Text(
              'Şubeler yüklenemedi.',
              style: TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadBranches,
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: FutureBuilder<List<Branch>>(
          future: _branchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (snapshot.hasError) {
              return _buildError();
            }

            final branches = snapshot.data ?? [];

            if (branches.isEmpty) {
              return const Center(
                child: Text(
                  'Henüz aktif şube bulunmuyor.',
                  style: TextStyle(color: darkBrown, fontSize: 15),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
              children: [
                _buildHeader(),

                ...branches.map(_buildBranchCard),

                const SizedBox(height: 4),

                const Text(
                  'Seçtiğin şubeye göre menü ve fiyatlar gösterilir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9A806D), fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
