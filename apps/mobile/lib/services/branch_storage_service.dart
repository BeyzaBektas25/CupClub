import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BranchStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Seçilen şube ID'sini kaydet
  Future<void> saveBranchId(int branchId) async {
    await _storage.write(key: 'selected_branch_id', value: branchId.toString());
  }

  // Kayıtlı şube ID'sini getir
  Future<String?> getBranchId() async {
    return await _storage.read(key: 'selected_branch_id');
  }

  // Kayıtlı şube ID'sini sil
  Future<void> clearBranchId() async {
    await _storage.delete(key: 'selected_branch_id');
  }
}
