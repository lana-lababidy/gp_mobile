import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final DioClient client;
  AuthApi(this.client);

  // نفس الدالة لكن غيّرنا اسم الحقل ليتطابق مع Postman
  Future<Map<String, dynamic>> generateOtpMobile(
      {required String phone}) async {
    final res = await client.dio.post(
      '/generate-otp',
      data: {'mobile_number': phone}, // ✅ بدل 'phone'
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return (res.data is Map)
        ? Map<String, dynamic>.from(res.data)
        : {'raw': res.data};
  }

  // نخلّي الباسورد اختياري، ونرسل نفس ما اشتغل معك ببوستمان
  Future<Map<String, dynamic>> loginClient({
    required String phone,
    String? password, // ✅ اختياري
  }) async {
    final payload = <String, dynamic>{
      'mobile_number': phone, // ✅ أهم تعديل
    };
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final res = await client.dio.post(
      '/login-client',
      data: payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data)
        : {'raw': res.data};

    final token = data['token'] ??
        data['data']?['token'] ??
        data['access_token'] ??
        data['auth']?['token'];

    if (token is String && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
    return data;
  }

  Future<Map<String, dynamic>> continueWithMobile({
    required String phone,
    required String otp,
  }) async {
    final res = await client.dio.post(
      '/cwm',
      data: {
        'mobile_number': phone, // ✅ بدل 'phone'
        'otp': otp,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data)
        : {'raw': res.data};

    final token = data['token'] ??
        data['data']?['token'] ??
        data['access_token'] ??
        data['auth']?['token'];

    if (token is String && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
    return data;
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
