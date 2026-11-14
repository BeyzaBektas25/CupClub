import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class ApiService {
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
}
