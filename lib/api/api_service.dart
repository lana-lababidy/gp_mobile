// lib/api/api_service.dart
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class ApiService {
  /// إرسال رمز OTP
  static Future<void> sendOtp({required String mobileNumber}) async {
    // المحاولة 1: x-www-form-urlencoded بالحقل mobile_number
    var res = await http.post(
      Uri.parse(ApiConstants.sendOtp),
      headers: {
        'Accept': 'application/json',
        // لا تحدد Content-Type ليبعث كـ form-urlencoded تلقائيًا
      },
      body: {
        'mobile_number': mobileNumber,
      },
    );

    // بعض الـ backends ترجع 401/422 إذا الاسم غلط — جرب mobile كبديل
    if (res.statusCode == 401 ||
        res.statusCode == 400 ||
        res.statusCode == 422) {
      res = await http.post(
        Uri.parse(ApiConstants.sendOtp),
        headers: {'Accept': 'application/json'},
        body: {
          'mobile': mobileNumber, // fallback
        },
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل الإرسال: ${res.statusCode} ${res.body}');
    }
  }

  /// التحقق من رمز OTP
  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    // المحاولة 1: x-www-form-urlencoded بالحقلين mobile_number + otp
    var res = await http.post(
      Uri.parse(ApiConstants.verifyOtp),
      headers: {'Accept': 'application/json'},
      body: {
        'mobile_number': mobileNumber,
        'otp': otp,
      },
    );

    // fallback إذا الاسم مختلف
    if (res.statusCode == 401 ||
        res.statusCode == 400 ||
        res.statusCode == 422) {
      res = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: {'Accept': 'application/json'},
        body: {
          'mobile': mobileNumber, // fallback
          'otp': otp,
        },
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل التحقق: ${res.statusCode} ${res.body}');
    }
  }
}
