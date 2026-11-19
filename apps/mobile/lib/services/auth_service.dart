import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config/api_config.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Ortak POST isteği
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/$endpoint');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = Map<String, dynamic>.from(jsonDecode(response.body));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data['message'];

    throw Exception(
      message is List ? message.join(', ') : message ?? 'Bir hata oluştu.',
    );
  }

  // Kullanıcı girişi
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('login', {'email': email, 'password': password});

    // Giriş başarılıysa token'ı güvenli alana kaydet
    final token = data['access_token'];

    if (token != null) {
      await _storage.write(key: 'access_token', value: token);
    }

    return data;
  }

  // Yeni kullanıcı kaydı
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    return await _post('register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    });
  }

  // Kayıtlı token'ı getir
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Kayıtlı token'ın geçerli olup olmadığını kontrol et
  Future<bool> validateToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/me');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return false;
    }

    throw Exception('Oturum kontrol edilemedi. Sunucu hatası.');
  }

  // Oturumu kapat
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}
