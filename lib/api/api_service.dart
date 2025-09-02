// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// عدّلنا العنوان إلى خادمكم المباشر
  static const String baseUrl = 'https://abshir-api.justfortesting.ovh/api';

  /// مهلة الشبكة (اختياري بس مفيد)
  static const Duration _timeout = Duration(seconds: 15);

  /// إرسال رمز OTP إلى الرقم
  static Future<void> sendOtp({required String phone}) async {
    final url = Uri.parse('$baseUrl/send-otp');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'فشل إرسال الرمز');
    }
  }

  /// التحقق من رمز OTP
  static Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone, 'code': code}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'رمز غير صحيح أو منتهي');
    }
  }

  /// محاولة استخراج رسالة خطأ من JSON
  static String? _extractError(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['error'] != null) return json['error'].toString();
      if (json is Map && json['reason'] != null)
        return json['reason'].toString();
      if (json is Map && json['message'] != null)
        return json['message'].toString();
    } catch (_) {
      // تجاهل: الرد ليس JSON
    }
    return null;
  }
}
