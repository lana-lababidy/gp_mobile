// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // إرسال الرمز
  static Future<SendOtpResult> sendOtp({required String phone}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtpPath}');
    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mobile_number': phone}), // <-- أهم نقطة
        )
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body) ?? 'فشل إرسال الرمز');
    }

    final data = _safeJson(res.body);
    return SendOtpResult(
      ok: (data['ok'] == true) || res.statusCode == 200,
      devCode: data['devCode']?.toString(), // لو بيرجع كود للتجربة
      message: data['message']?.toString(),
    );
  }

  // التحقق من الرمز (المسار مؤقت لحين تأكيد لانا)
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
      throw Exception(_extractError(res.body) ??
          'لم يتم التحقق من الرمز (قد يكون مسار التحقق مختلف)');
    }

    final data = _safeJson(res.body);
    return VerifyOtpResult(
      ok: (data['ok'] == true) || res.statusCode == 200,
      accessToken: data['accessToken']?.toString(),
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
  final String? devCode;
  final String? message;
  SendOtpResult({required this.ok, this.devCode, this.message});
}

class VerifyOtpResult {
  final bool ok;
  final String? accessToken;
  final String? message;
  VerifyOtpResult({required this.ok, this.accessToken, this.message});
}
