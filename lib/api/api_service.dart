// lib/api/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  /// إرسال الرمز / محاولة تسجيل الدخول
  /// JSON body: { "mobile_number": "09XXXXXXXX" }
  static Future<SendOtpResult> sendOtp({required String phone}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtpPath}');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'mobile_number': phone});

    if (kDebugMode) {
      debugPrint('REQ URL  -> $url');
      debugPrint('HEADERS  -> $headers');
      debugPrint('BODY     -> $body');
    }

    final res = await http
        .post(url, headers: headers, body: body)
        .timeout(ApiConfig.requestTimeout);

    if (kDebugMode) {
      debugPrint('STATUS   -> ${res.statusCode}');
      debugPrint('RESP     -> ${res.body}');
    }

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'فشل إرسال الطلب');
    }

    final data = _safeJson(res.body);
    return SendOtpResult(
      ok: true,
      token: data['token']?.toString(), // إذا رجع توكن = لوجين فوري
      user: data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)
          : null,
      message: data['message']?.toString(),
      devCode: data['devCode']?.toString(), // ببيئة dev إذا متوفر
    );
  }

  /// التحقق من الرمز
  /// JSON body: { "mobile_number": "09XXXXXXXX", "code": "1234" }
  static Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtpPath}');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'mobile_number': phone, 'code': code});

    if (kDebugMode) {
      debugPrint('REQ URL  -> $url');
      debugPrint('HEADERS  -> $headers');
      debugPrint('BODY     -> $body');
    }

    final res = await http
        .post(url, headers: headers, body: body)
        .timeout(ApiConfig.requestTimeout);

    if (kDebugMode) {
      debugPrint('STATUS   -> ${res.statusCode}');
      debugPrint('RESP     -> ${res.body}');
    }

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
  final String? token; // إذا موجود: دخول فوري
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
