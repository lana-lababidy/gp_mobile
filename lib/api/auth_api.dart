// lib/api/auth_api.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';

class AuthApi {
  final DioClient client;
  AuthApi(this.client);

  Map<String, dynamic> _asMap(dynamic data) {
    return (data is Map) ? Map<String, dynamic>.from(data) : {'raw': data};
  }

  String _friendlyError(DioException e,
      {String fallback = 'Invalid Parameters'}) {
    final d = e.response?.data;
    if (d is Map) {
      if (d['message'] is String) return d['message'];
      if (d['errors'] is Map && d['errors'].isNotEmpty) {
        final firstKey = (d['errors'] as Map).keys.first;
        final val = d['errors'][firstKey];
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

  // لو عندكم توليد OTP منفصل
  Future<Map<String, dynamic>> generateOtpMobile(
      {required String phone}) async {
    try {
      final res = await client.dio.post(
        '/generate-otp',
        data: {'mobile_number': phone}, // ✅ يطابق Postman
      );
      return _asMap(res.data);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // التحقق بوساطة OTP (إن وجِد)
  Future<Map<String, dynamic>> continueWithMobile({
    required String phone,
    required String otp,
  }) async {
    try {
      final res = await client.dio.post(
        '/cwm',
        data: {'mobile_number': phone, 'otp': otp}, // ✅ يطابق Postman
      );
      final data = _asMap(res.data);
      await _saveTokenIfExists(data);
      return data;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // تسجيل/دخول حسب ما اشتغل معك ببوستمان
  Future<Map<String, dynamic>> loginClient({
    required String phone,
    String? password, // اختياري
  }) async {
    try {
      final payload = <String, dynamic>{'mobile_number': phone};
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await client.dio.post('/login-client', data: payload);
      final data = _asMap(res.data);
      await _saveTokenIfExists(data);
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
    }
  }
}
