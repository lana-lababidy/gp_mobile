// lib/api/api_service.dart
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class ApiService {
  /// إرسال رمز OTP كـ form-urlencoded:
  /// body: mobile_number=09XXXXXXXX
  static Future<void> sendOtp({required String mobileNumber}) async {
    final uri = Uri.parse(ApiConstants.sendOtp);

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        // مامنحط Content-Type → الافتراضي x-www-form-urlencoded
      },
      body: {
        'mobile_number': mobileNumber,
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل الإرسال: ${res.statusCode} ${res.body}');
    }
  }

  /// التحقق من الرمز كـ form-urlencoded:
  /// body: mobile_number=...&otp=....
  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConstants.verifyOtp);

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'mobile_number': mobileNumber,
        'otp': otp,
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل التحقق: ${res.statusCode} ${res.body}');
    }
  }
}
