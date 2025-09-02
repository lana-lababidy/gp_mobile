// lib/constants/api.dart
class ApiConstants {
  static const String baseUrl = "https://abshir-api.justfortesting.ovh/api";

  // إرسال رمز OTP
  static const String sendOtp = "$baseUrl/auth/send-otp";

  // التحقق من رمز OTP
  static const String checkOtp = "$baseUrl/cwm";
}
