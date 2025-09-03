// lib/api/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class ApiService {
  static String toPlus963(String nine) {
    if (nine.startsWith('09') && nine.length == 10) {
      return '+963${nine.substring(1)}';
    }
    return nine;
  }

  /// إرسال رمز OTP
  static Future<void> sendOtp({required String mobileNumber}) async {
    final plus = toPlus963(mobileNumber);
    final uri = Uri.parse(ApiConstants.sendOtp);

    // المحاولة 1: +963
    var res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({"mobile_number": plus}),
    );
    if (kDebugMode)
      debugPrint('SEND OTP (+963) -> ${res.statusCode} ${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) return;

    // المحاولة 2: 09
    res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({"mobile_number": mobileNumber}),
    );
    if (kDebugMode)
      debugPrint('SEND OTP (09) -> ${res.statusCode} ${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) return;

    throw Exception('فشل الإرسال: ${res.statusCode} ${res.body}');
  }

  /// التحقق من OTP
  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConstants.verifyOtp);
    final body = jsonEncode({"mobile_number": mobileNumber, "otp": otp});

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: body,
    );
    if (kDebugMode) debugPrint('VERIFY OTP -> ${res.statusCode} ${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل التحقق: ${res.statusCode} ${res.body}');
    }
  }
}
