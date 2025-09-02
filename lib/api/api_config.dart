// lib/api/api_config.dart
/// ملف ضبط موحّد لنقاط اتصال الـ OTP وخيارات الشبكة.
/// عدّل قيمة [baseUrl] حسب بيئة التشغيل لديك.
///
/// ملاحظات:
/// - على محاكي أندرويد استخدم 10.0.2.2 بدل localhost.
/// - في الإنتاج استخدم الدومين HTTPS.
class ApiConfig {
  /// ====== اختر واحدة من الأسطر التالية حسب بيئتك ======
  // للإنتاج (الدومين):
  static String baseUrl = 'https://abshir-api.justfortesting.ovh/api';

  // للتطوير على محاكي أندرويد ضد سيرفر محلي على جهازك:
  // static String baseUrl = 'http://10.0.2.2:8000/api';

  // للتطوير على جهاز حقيقي داخل نفس الشبكة (بدّل الـ IP):
  // static String baseUrl = 'http://192.168.1.100:8000/api';
  /// =====================================================

  /// مسار إرسال الطلب (حسب لانا)
  static const String sendOtpPath = '/login-client';

  /// مسار التحقق من الكود (مؤقت لحين تأكيده من الباك إند)
  static const String verifyOtpPath = '/verify-client';

  /// مهلة الطلبات الشبكية
  static const Duration requestTimeout = Duration(seconds: 15);

  /// عناوين كاملة جاهزة للاستخدام
  static Uri sendOtpUri() => Uri.parse('$baseUrl$sendOtpPath');
  static Uri verifyOtpUri() => Uri.parse('$baseUrl$verifyOtpPath');
}
