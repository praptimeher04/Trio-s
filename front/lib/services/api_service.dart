import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Primary IPv4 loopback to avoid Windows IPv6 (::1) localhost resolution issues in Web/Chrome
  static const List<String> baseUrls = [
    'http://127.0.0.1:8085/api/auth',
    'http://localhost:8085/api/auth',
    'http://10.0.2.2:8085/api/auth', // Android Emulator fallback
  ];

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    Object? lastError;

    for (final baseUrl in baseUrls) {
      final url = Uri.parse('$baseUrl/register');
      if (kDebugMode) {
        print('🚀 [API REQ] POST $url');
        print('Payload: name=$name, email=$email, role=$role');
      }

      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                'name': name,
                'email': email,
                'role': role,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (kDebugMode) {
          print('📥 [API RES] Code: ${response.statusCode}');
          print('Body: ${response.body}');
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'User registered successfully in database!',
            'name': data['name'] ?? name,
            'email': data['email'] ?? email,
            'role': data['role'] ?? role,
          };
        } else {
          Map<String, dynamic> data = {};
          try {
            data = jsonDecode(response.body);
          } catch (_) {}
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed with code ${response.statusCode}.',
          };
        }
      } catch (e) {
        lastError = e;
        if (kDebugMode) {
          print('⚠️ [API ATTEMPT FAILED] $baseUrl/register: $e');
        }
      }
    }

    if (kDebugMode) {
      print('❌ [API ERROR ALL HOSTS FAILED] $lastError');
    }
    return {
      'success': false,
      'message': 'Cannot connect to Spring Boot backend (Port 8085). Ensure Spring Boot server is running.',
    };
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    Object? lastError;

    for (final baseUrl in baseUrls) {
      final url = Uri.parse('$baseUrl/login');
      if (kDebugMode) {
        print('🚀 [API REQ] POST $url');
        print('Payload: email=$email');
      }

      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({
                'email': email,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (kDebugMode) {
          print('📥 [API RES] Code: ${response.statusCode}');
          print('Body: ${response.body}');
        }

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Login authenticated successfully!',
            'name': data['name'] ?? 'Hitija Mhatre',
            'email': data['email'] ?? email,
            'role': data['role'] ?? 'Student',
          };
        } else {
          Map<String, dynamic> data = {};
          try {
            data = jsonDecode(response.body);
          } catch (_) {}
          return {
            'success': false,
            'message': data['message'] ?? 'Invalid email or password credentials.',
          };
        }
      } catch (e) {
        lastError = e;
        if (kDebugMode) {
          print('⚠️ [API ATTEMPT FAILED] $baseUrl/login: $e');
        }
      }
    }

    if (kDebugMode) {
      print('❌ [API ERROR ALL HOSTS FAILED] $lastError');
    }
    return {
      'success': false,
      'message': 'Cannot connect to Spring Boot backend (Port 8085). Ensure Spring Boot server is running.',
    };
  }
}
