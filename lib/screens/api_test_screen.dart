import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/dio_client.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'اضغط الزر لتجربة الاتصال';
  bool _loading = false;

  Future<void> _callTest() async {
    setState(() {
      _loading = true;
      _result = 'جاري الطلب...';
    });
    try {
      final dio = context.read<DioClient>().dio;
      final res = await dio.get('/test'); // GET http://10.0.2.2:8000/api/test
      setState(() {
        _result = res.data.toString();
      });
    } catch (e) {
      setState(() {
        _result = 'خطأ: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _callTest,
                child: const Text('اتصل بـ GET /test'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
