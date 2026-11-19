import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/branch.dart';
import '../models/branch_product.dart';
import '../models/product_option_group.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<void> getProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/products');

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

  Future<List<Branch>> getBranches() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/branches');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) {
          return Branch.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else {
        throw Exception('Şubeler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Şube bağlantı hatası: $e');
      rethrow;
    }
  }

  Future<List<BranchProduct>> getBranchProducts(int branchId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/branches/$branchId/products',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) {
          return BranchProduct.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else {
        throw Exception('Ürünler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ürün bağlantı hatası: $e');
      rethrow;
    }
  }

  Future<List<ProductOptionGroup>> getProductOptions(
    int branchId,
    int productId,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/branches/$branchId/products/$productId/options',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) {
          return ProductOptionGroup.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else {
        throw Exception('Ürün seçenekleri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ürün seçenekleri bağlantı hatası: $e');
      rethrow;
    }
  }

  // Sipariş oluşturur.
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int branchId,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'branchId': branchId,
        'items': items,
      }),
    );

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    final message = data is Map ? data['message'] : null;

    throw Exception(
      message is List
          ? message.join(', ')
          : message ?? 'Sipariş oluşturulamadı.',
    );
  }
}
