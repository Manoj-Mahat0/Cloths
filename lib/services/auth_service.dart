import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://backend.cloths.systaio.com';
  static String get baseUrl => _baseUrl;

  static const String _keyAccessToken = 'access_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyFullName = 'full_name';
  static const String _keyRole = 'role';
  static const String _keyIsVerified = 'is_verified';
  static const String _keyIsActive = 'is_active';
  static const String _keyUserId = 'user_id';

  Future<Map<String, dynamic>> register({
    required String username,
    required String fullName,
    required String password,
    required String role,
    required String email,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/auth/register');
    final http.Response resp = await http.post(
      uri,
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'full_name': fullName,
        'password': password,
        'role': role,
        'email': email,
      }),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      await _saveUserProfile(data);
      return data;
    }
    throw HttpException('Register failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> requestOtp({required String usernameOrEmail}) async {
    final Uri uri = Uri.parse('$_baseUrl/auth/request-otp');
    final http.Response resp = await http.post(
      uri,
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'username_or_email': usernameOrEmail,
      }),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['sent'] as bool?) ?? false;
    }
    throw HttpException('Request OTP failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<AuthToken> verifyOtp({
    required String username,
    required String otp,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/auth/token-otp');
    final http.Response resp = await http.post(
      uri,
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'otp': otp,
      }),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      final AuthToken token = AuthToken(
        accessToken: data['access_token'] as String,
        tokenType: data['token_type'] as String? ?? 'bearer',
      );
      await _saveToken(token);
      // persist username for convenience
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUsername, username);
      return token;
    }
    throw HttpException('Verify OTP failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> resendOtp({required String username}) async {
    final Uri uri = Uri.parse('$_baseUrl/auth/resend-otp?username=$username');
    final http.Response resp = await http.post(
      uri,
      headers: <String, String>{
        'accept': 'application/json',
      },
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['sent'] as bool?) ?? false;
    }
    throw HttpException('Resend OTP failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyTokenType);
  }

  Future<Map<String, dynamic>?> fetchCurrentUserAndPersist() async {
    final String? token = await getStoredAccessToken();
    if (token == null || token.isEmpty) return null;
    final Uri uri = Uri.parse('$_baseUrl/user/me');
    final http.Response resp = await http.get(
      uri,
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      // Persist role and username/id if returned
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (data.containsKey('role') && data['role'] != null) await prefs.setString(_keyRole, data['role'] as String);
      if (data.containsKey('username') && data['username'] != null) await prefs.setString(_keyUsername, data['username'] as String);
      if (data.containsKey('id') && data['id'] != null) await prefs.setInt(_keyUserId, (data['id'] as num).toInt());
      return data;
    }
    throw HttpException('Fetch current user failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<void> _saveToken(AuthToken token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token.accessToken);
    await prefs.setString(_keyTokenType, token.tokenType);
  }

  Future<void> _saveUserProfile(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data.containsKey('username')) await prefs.setString(_keyUsername, data['username'] as String);
    if (data.containsKey('email') && data['email'] != null) await prefs.setString(_keyEmail, data['email'] as String);
    if (data.containsKey('full_name') && data['full_name'] != null) await prefs.setString(_keyFullName, data['full_name'] as String);
    if (data.containsKey('role') && data['role'] != null) await prefs.setString(_keyRole, data['role'] as String);
    if (data.containsKey('is_verified') && data['is_verified'] != null) await prefs.setBool(_keyIsVerified, data['is_verified'] as bool);
    if (data.containsKey('is_active') && data['is_active'] != null) await prefs.setBool(_keyIsActive, data['is_active'] as bool);
    if (data.containsKey('id') && data['id'] != null) await prefs.setInt(_keyUserId, (data['id'] as num).toInt());
  }

  static Future<bool> hasValidSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getStoredRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getStoredUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getStoredAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<Map<String, String>> getHeaders() async {
    final String? token = await getStoredAccessToken();
    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}

class AuthToken {
  AuthToken({required this.accessToken, required this.tokenType});

  final String accessToken;
  final String tokenType;
}

class HttpException implements Exception {
  HttpException(this.message, {required this.statusCode, this.body});

  final String message;
  final int statusCode;
  final String? body;

  @override
  String toString() => 'HttpException($statusCode): $message ${body ?? ''}';
}