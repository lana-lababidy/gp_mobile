// lib/api/api_config.dart
class ApiConfig {
  // اختر البيئة
  static const bool useProd = true;

  static const String devBaseUrl = 'http://10.0.2.2:8000/api';
  static const String prodBaseUrl = 'https://abshir-api.justfortesting.ovh/api';

  static String get baseUrl => useProd ? prodBaseUrl : devBaseUrl;

  // ⬅️ الإرسال والتحقق كلاهما على /cwm
  static const String sendOtpPath = '/cwm';
  static const String verifyOtpPath = '/cwm';

  static const Duration requestTimeout = Duration(seconds: 20);
}
