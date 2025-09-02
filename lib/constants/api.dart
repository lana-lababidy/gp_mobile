// lib/constants/api.dart
class ApiConstants {
  static const String baseUrl = "https://abshir-api.justfortesting.ovh/api";

  // إرسال OTP
  static const String sendOtp = "$baseUrl/cwm";

  // التحقق من OTP
  static const String verifyOtp = "$baseUrl/cwm";
}
