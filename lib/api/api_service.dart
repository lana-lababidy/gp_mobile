// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class ApiService {
  /// إرسال رمز OTP
  static Future<void> sendOtp({required String mobileNumber}) async {
    final res = await http.post(
      Uri.parse(ApiConstants.sendOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "mobile_number": mobileNumber,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل الإرسال: ${res.statusCode} ${res.body}');
    }
  }

  /// التحقق من رمز OTP
  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "mobile_number": mobileNumber,
        "otp": otp,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل التحقق: ${res.statusCode} ${res.body}');
    }
  }
}
