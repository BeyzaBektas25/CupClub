import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/branch_list_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/branch_storage_service.dart';

void main() {
  runApp(const CupClubApp());
}

class CupClubApp extends StatelessWidget {
  const CupClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CupClub',
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final BranchStorageService _branchStorage = BranchStorageService();

  late Future<Widget> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _checkSession();
  }

  // Uygulama açıldığında oturumu kontrol eder
  Future<Widget> _checkSession() async {
    final isValid = await _authService.validateToken();

    // Geçerli bir oturum yoksa giriş ekranına git
    if (!isValid) {
      return const LoginScreen();
    }

    // Daha önce seçilmiş şubeyi kontrol et
    final savedBranchId = await _branchStorage.getBranchId();

    if (savedBranchId == null) {
      return const BranchListScreen();
    }

    final branchId = int.tryParse(savedBranchId);

    if (branchId == null) {
      return const BranchListScreen();
    }

    // Şubeleri API üzerinden getir
    final branches = await _apiService.getBranches();

    // Kayıtlı şubeyi bul
    for (final branch in branches) {
      if (branch.id == branchId) {
        return HomeScreen(selectedBranch: branch);
      }
    }

    // Kayıtlı şube artık bulunamıyorsa şube seçimine git
    return const BranchListScreen();
  }

  // Kontrol başarısız olursa tekrar denemeyi sağlar
  void _retry() {
    setState(() {
      _startupFuture = _checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bağlantı kurulamadı. Lütfen tekrar deneyin.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        }

        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}
