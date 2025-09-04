// lib/api/auth_api.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class AuthApi {
  final DioClient client;
  AuthApi(this.client);

  // ---------- Helpers ----------
  Map<String, dynamic> _asMap(dynamic data) =>
      (data is Map) ? Map<String, dynamic>.from(data) : {'raw': data};

  String _friendlyError(DioException e,
      {String fallback = 'Invalid Parameters'}) {
    final d = e.response?.data;
    if (d is Map) {
      if (d['message'] is String) return d['message'];
      if (d['errors'] is Map && d['errors'].isNotEmpty) {
        final firstKey = (d['errors'] as Map).keys.first;
        final val = (d['errors'] as Map)[firstKey];
        if (val is List && val.isNotEmpty) return val.first.toString();
        return val.toString();
      }
    } else if (d is String && d.trim().isNotEmpty) {
      return d;
    }
    return fallback;
  }

  Future<void> _saveTokenIfExists(Map<String, dynamic> data) async {
    final token = data['token'] ??
        data['data']?['token'] ??
        data['access_token'] ??
        data['auth']?['token'];
    if (token is String && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  Future<void> _saveUserIfExists(Map<String, dynamic> data) async {
    final user = data['data'] ?? data['user'] ?? data['profile'];
    if (user is Map) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user));
    }
  }

  // ---------- API ----------
  // توليد/إرسال رمز OTP
  Future<Map<String, dynamic>> generateOtpMobile(
      {required String phone}) async {
    try {
      final res = await client.dio.post(
        '/generate-otp',
        data: {'mobile_number': phone}, // مطابق لـ Postman
      );
      return _asMap(res.data); // عادةً: { message, data: 4-digit code }
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // تأكيد الرمز والولوج (يرجع بيانات المستخدم)
  Future<Map<String, dynamic>> continueWithMobile({
    required String phone,
    required String otp,
  }) async {
    try {
      final res = await client.dio.post(
        '/cwm',
        data: {'mobile_number': phone, 'otp': otp},
      );
      final data = _asMap(res.data);

      await _saveTokenIfExists(data); // إذا رجع توكن
      await _saveUserIfExists(data); // يحفظ user من data{}

      return data;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // تسجيل/دخول بديل (إن احتجته)
  Future<Map<String, dynamic>> loginClient({
    required String phone,
    String? password,
  }) async {
    try {
      final payload = <String, dynamic>{'mobile_number': phone};
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }
      final res = await client.dio.post('/login-client', data: payload);
      final data = _asMap(res.data);

      await _saveTokenIfExists(data);
      await _saveUserIfExists(data);

      return data;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<void> logoutClient() async {
    try {
      await client.dio.post('/logout-client');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user');
    }
  }

  // ---------- Accessors (اختيارية) ----------
  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('user');
    if (s == null || s.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(s));
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
