// نقطة ضبط واحدة لمسارات الـ OTP
class ApiConfig {
  static String baseUrl = 'https://abshir-api.justfortesting.ovh/api';

  // من لانا:
  static String sendOtpPath = '/login-client';

  // بانتظار لانا تعطينا مسار التحقق النهائي (مؤقتاً اسم افتراضي):
  static String verifyOtpPath = '/verify-client';

  static Duration requestTimeout = const Duration(seconds: 15);
}
