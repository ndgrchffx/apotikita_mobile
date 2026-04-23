import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://apotikitamobile-production.up.railway.app/api';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- AUTH ---
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['access_token']);
        // Simpan role dan email
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', data['role'] ?? 'user');
        await prefs.setString('user_email', email);
        return data['role'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('role');
    await prefs.remove('user_email');
  }

  // --- MEDICINES ---
  static Future<List<dynamic>> getMedicines() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/medicines'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle both list and object with data key
      if (data is List) return data;
      if (data is Map && data['data'] != null) return data['data'];
      return [];
    }
    throw Exception('Gagal mengambil data obat');
  }

  static Future<bool> addMedicine(Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/medicines'),
      headers: headers,
      body: json.encode(data),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateMedicine(int id, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: headers,
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteMedicine(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: headers,
    );
    return response.statusCode == 200;
  }
}
