// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  /// إرسال الرمز / محاولة تسجيل الدخول
  /// - يرسل mobile_number إلى /login-client
  /// - إن رجع token من السيرفر نعتبره Login ناجح
  static Future<SendOtpResult> sendOtp({required String phone}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtpPath}');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mobile_number': phone}),
        )
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'فشل إرسال الطلب');
    }

    final data = _safeJson(res.body);
    return SendOtpResult(
      ok: true,
      token: data['token']?.toString(), // <-- مهم
      user: data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)
          : null,
      message: data['message']?.toString(),
      devCode: data['devCode']?.toString(), // لو موجود ببيئة dev
    );
  }

  /// التحقق من الرمز (نفعّلها لما يوصِل مسار التحقق النهائي)
  static Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtpPath}');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mobile_number': phone, 'code': code}),
        )
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'رمز غير صحيح أو منتهي');
    }

    final data = _safeJson(res.body);
    return VerifyOtpResult(
      ok: true,
      accessToken: data['token']?.toString() ?? data['accessToken']?.toString(),
      message: data['message']?.toString(),
    );
  }

  // ===== Helpers =====
  static Map<String, dynamic> _safeJson(String body) {
    try {
      final j = jsonDecode(body);
      return (j is Map<String, dynamic>) ? j : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String? _extractError(String body) {
    final j = _safeJson(body);
    return j['error']?.toString() ??
        j['reason']?.toString() ??
        j['message']?.toString();
  }
}

class SendOtpResult {
  final bool ok;
  final String? token; // <-- جديد
  final Map<String, dynamic>? user;
  final String? message;
  final String? devCode;

  SendOtpResult({
    required this.ok,
    this.token,
    this.user,
    this.message,
    this.devCode,
  });
}

class VerifyOtpResult {
  final bool ok;
  final String? accessToken;
  final String? message;

  VerifyOtpResult({
    required this.ok,
    this.accessToken,
    this.message,
  });
}
