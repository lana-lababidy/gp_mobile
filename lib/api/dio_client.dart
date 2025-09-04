// lib/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  late final Dio dio;

  // ✅ صار عندو مُعامل baseUrl متل ما عم تناديه بـ main.dart
  DioClient({required String baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // هيدر التوكن تلقائياً + ضمان Accept/Content-Type
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Accept'] ??= 'application/json';
          options.headers['Content-Type'] ??= 'application/json';

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );

    // لوج مفيد أثناء التطوير
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        requestHeader: false,
      ),
    );
  }
}
