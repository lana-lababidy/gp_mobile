// lib/api/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';

class ApiService {
  // جرّب مجموعة محاولات لغاية ما يزبط واحد (2xx)
  static Future<http.Response> _tryMany(
      List<Future<http.Response>> attempts) async {
    http.Response? last;
    for (final a in attempts) {
      try {
        final res = await a;
        if (res.statusCode >= 200 && res.statusCode < 300) return res;
        last = res;
      } catch (_) {}
    }
    throw Exception('فشل الطلب: ${last?.statusCode} ${last?.body}');
  }

  static String _toPlus963(String nine) {
    // إدخال متوقع 09XXXXXXXX → +9639XXXXXXXX
    if (nine.startsWith('09') && nine.length == 10) {
      return '+963' + nine.substring(1); // +9639XXXXXXXX
    }
    return nine;
  }

  /// إرسال رمز OTP
  static Future<void> sendOtp({required String mobileNumber}) async {
    final nine = mobileNumber; // 09XXXXXXXX
    final plus = _toPlus963(mobileNumber); // +9639XXXXXXXX

    final urls = [ApiConstants.sendOtp]; // عادة نفس /cwm

    // محاولات form-urlencoded بأسماء حقول مختلفة وصيغ رقم مختلفة
    final attempts = <Future<http.Response>>[];
    for (final url in urls) {
      for (final field in ['mobile_number', 'mobile', 'phone']) {
        for (final value in [nine, plus]) {
          // 1) x-www-form-urlencoded
          attempts.add(http.post(
            Uri.parse(url),
            headers: {'Accept': 'application/json'},
            body: {field: value},
          ));
          // 2) JSON
          attempts.add(http.post(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({field: value}),
          ));
        }
      }
    }

    await _tryMany(attempts);
  }

  /// التحقق من رمز OTP
  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final nine = mobileNumber;
    final plus = _toPlus963(mobileNumber);

    final urls = [ApiConstants.verifyOtp];

    final attempts = <Future<http.Response>>[];
    for (final url in urls) {
      for (final field in ['mobile_number', 'mobile', 'phone']) {
        for (final value in [nine, plus]) {
          // 1) x-www-form-urlencoded
          attempts.add(http.post(
            Uri.parse(url),
            headers: {'Accept': 'application/json'},
            body: {field: value, 'otp': otp},
          ));
          // 2) JSON
          attempts.add(http.post(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({field: value, 'otp': otp}),
          ));
        }
      }
    }

    await _tryMany(attempts);
  }
}
