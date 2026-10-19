
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String fiqhApiUrl =
    'https://fiqhmedia-backend-production.up.railway.app';

class FiqhUser {
  final int id;
  final String email;
  final String role;

  const FiqhUser({
    required this.id,
    required this.email,
    required this.role,
  });

  bool get isAdmin =>
      role == 'super_admin' || role == 'admin';

  factory FiqhUser.fromJson(Map<String, dynamic> data) {
    return FiqhUser(
      id: (data['id'] as num).toInt(),
      email: data['email'] as String,
      role: data['role'] as String,
    );
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class FiqhAuthService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _tokenKey = 'fiqhmedia_auth_token';

  static Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<FiqhUser?> restoreSession() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$fiqhApiUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        await logout();
        return null;
      }

      if (response.statusCode != 200) {
        throw const AuthException(
          'Server bilan bog‘lanib bo‘lmadi.',
        );
      }

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      return FiqhUser.fromJson(data);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Internet aloqasini tekshiring.',
      );
    }
  }

  static Future<FiqhUser> login({
    required String email,
    required String password,
  }) {
    return _authenticate(
      endpoint: '/auth/login',
      email: email,
      password: password,
    );
  }

  static Future<FiqhUser> register({
    required String email,
    required String password,
  }) {
    return _authenticate(
      endpoint: '/auth/register',
      email: email,
      password: password,
    );
  }

  static Future<FiqhUser> _authenticate({
    required String endpoint,
    required String email,
    required String password,
  }) async {
    http.Response response;

    try {
      response = await http.post(
        Uri.parse('$fiqhApiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const AuthException(
        'Internet yoki server bilan aloqa yo‘q.',
      );
    }

    if (response.statusCode == 401) {
      throw const AuthException(
        'Email yoki parol noto‘g‘ri.',
      );
    }

    if (response.statusCode == 403) {
      throw const AuthException(
        'Bu akkaunt uchun ro‘yxatdan o‘tish '
        'cheklangan. Login orqali kiring.',
      );
    }

    if (response.statusCode == 409) {
      throw const AuthException(
        'Bu email allaqachon ro‘yxatdan o‘tgan.',
      );
    }

    if (response.statusCode == 422) {
      throw const AuthException(
        'Email va parolni tekshiring. '
        'Parol kamida 12 belgidan iborat bo‘lsin.',
      );
    }

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw AuthException(
        'Server xatosi: ${response.statusCode}',
      );
    }

    try {
      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final token = data['access_token'] as String;

      final user = FiqhUser.fromJson(
        data['user'] as Map<String, dynamic>,
      );

      await _storage.write(
        key: _tokenKey,
        value: token,
      );

      return user;
    } catch (_) {
      throw const AuthException(
        'Login javobini qayta ishlashda xatolik.',
      );
    }
  }

  static Future<Map<String, dynamic>> adminStatus() async {
    final token = await getToken();

    if (token == null) {
      throw const AuthException(
        'Avval tizimga kiring.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$fiqhApiUrl/admin/status'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        await logout();
        throw const AuthException(
          'Sessiya tugagan. Qaytadan kiring.',
        );
      }

      if (response.statusCode == 403) {
        throw const AuthException(
          'Administrator ruxsati mavjud emas.',
        );
      }

      if (response.statusCode != 200) {
        throw AuthException(
          'Server xatosi: ${response.statusCode}',
        );
      }

      return jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Server bilan bog‘lanib bo‘lmadi.',
      );
    }
  }
}
