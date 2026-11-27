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

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'data': decoded};
  }

  Exception _responseException(
    Map<String, dynamic> data,
    String defaultMessage,
  ) {
    final message = data['message'];

    return Exception(
      message is List
          ? message.join(', ')
          : message?.toString() ?? defaultMessage,
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

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

  // Kupon kodunu sepet tutarına göre backend üzerinde değerlendirir.
  Future<Map<String, dynamic>> evaluateCoupon({
    required double cartTotal,
    required String couponCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/campaigns/evaluate');

    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'cartTotal': cartTotal,
        'couponCode': couponCode.trim().toUpperCase(),
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw _responseException(data, 'Kupon değerlendirilemedi.');
  }

  // Kullanıcının sadakat hesabını ve işlem geçmişini getirir.
  Future<Map<String, dynamic>> getLoyaltyAccount(int userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/loyalty/$userId');

    final response = await http.get(url, headers: await _authHeaders());

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw _responseException(data, 'Sadakat bilgileri alınamadı.');
  }

  // Kullanıcı için ödül QR kodu oluşturur.
  Future<Map<String, dynamic>> generateRewardQr(int userId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/loyalty/qr/generate/$userId',
    );

    final response = await http.post(url, headers: await _authHeaders());

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw _responseException(data, 'Ödül QR kodu oluşturulamadı.');
  }

  // Siparişi oluşturur. Kupon kodu gönderilmesi isteğe bağlıdır.
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int branchId,
    required List<Map<String, dynamic>> items,
    String? couponCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders');

    final body = <String, dynamic>{
      'userId': userId,
      'branchId': branchId,
      'items': items,
    };

    if (couponCode != null && couponCode.trim().isNotEmpty) {
      body['couponCode'] = couponCode.trim().toUpperCase();
    }

    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw _responseException(data, 'Sipariş oluşturulamadı.');
  }
}
