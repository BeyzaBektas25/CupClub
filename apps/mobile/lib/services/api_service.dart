import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/branch.dart';
import '../models/branch_product.dart';

class ApiService {
  // Bütün ürünleri getirir
  Future<void> getProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint('Ürünler başarıyla alındı:');
        debugPrint(data.toString());
      } else {
        debugPrint('Hata: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Bağlantı hatası: $e');
    }
  }

  // Şubeleri API'den getirir
  Future<List<Branch>> getBranches() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/branches');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final branches = data.map((item) {
          return Branch.fromJson(Map<String, dynamic>.from(item));
        }).toList();

        debugPrint('Şubeler başarıyla getirildi:');
        debugPrint(branches.toString());

        return branches;
      } else {
        throw Exception('Şubeler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Şube bağlantı hatası: $e');
      rethrow;
    }
  }

  // Seçilen şubenin ürünlerini getirir
  Future<List<BranchProduct>> getBranchProducts(int branchId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/branches/$branchId/products',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final products = data.map((item) {
          return BranchProduct.fromJson(Map<String, dynamic>.from(item));
        }).toList();

        debugPrint('Şubeye özel ürünler başarıyla getirildi:');
        debugPrint(products.toString());

        return products;
      } else {
        throw Exception('Ürünler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ürün bağlantı hatası: $e');
      rethrow;
    }
  }
}
