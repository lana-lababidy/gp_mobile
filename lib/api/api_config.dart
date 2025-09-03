// lib/api/api_config.dart
class ApiConfig {
  /// بدّل القيمة حسب البيئة
  static const bool useProd = true;

  static const String devBaseUrl = 'http://10.0.2.2:8000/api';
  static const String prodBaseUrl = 'https://abshir-api.justfortesting.ovh/api';

  static String get baseUrl => useProd ? prodBaseUrl : devBaseUrl;

  // المسارات الثابتة
  static const String sendOtpPath = '/auth/send-otp';
  static const String verifyOtpPath = '/cwm';

  // مهلة الطلبات
  static const Duration requestTimeout = Duration(seconds: 20);
}
