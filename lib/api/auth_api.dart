import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

class AuthApi {
  final DioClient client;
  AuthApi(this.client);

  Future<Map<String, dynamic>> generateOtpMobile(
      {required String phone}) async {
    final res = await client.dio.post('/generate-otp', data: {'phone': phone});
    return (res.data is Map)
        ? Map<String, dynamic>.from(res.data)
        : {'raw': res.data};
  }

  Future<Map<String, dynamic>> continueWithMobile({
    required String phone,
    required String otp,
  }) async {
    final res =
        await client.dio.post('/cwm', data: {'phone': phone, 'otp': otp});
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

  Future<Map<String, dynamic>> loginClient({
    required String phone,
    required String password,
  }) async {
    final res = await client.dio.post('/login-client', data: {
      'phone': phone,
      'password': password,
    });
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
