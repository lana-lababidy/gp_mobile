import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'phone_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _textController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  late AnimationController _glowController;
  late Animation<double> _glow;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    // أنيميشن الشعار (تكبير + Fade)
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // أنيميشن النصوص
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // توهج الشعار (Glow)
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // خلفية متدرجة متحركة
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    // تشغيل أنيميشن
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // بعد 5.5 ثانية → الانتقال
    Timer(const Duration(milliseconds: 5500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhoneScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.lerp(const Color(0xFF0A2A6C), const Color(0xFF2F66D4),
                      _bgController.value)!,
                  Color.lerp(const Color(0xFF2F66D4), const Color(0xFF0A2A6C),
                      _bgController.value)!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Particles بالخلفية
            Positioned.fill(child: CustomPaint(painter: ParticlePainter())),

            // الموجة بأسفل الشاشة
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 100,
                child: CustomPaint(
                  painter: WavePainter(_bgController.value),
                  child: Container(),
                ),
              ),
            ),

            // المحتوى الأساسي
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الشعار مع توهج
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: AnimatedBuilder(
                        animation: _glow,
                        builder: (context, _) {
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: _glow.value,
                                  spreadRadius: _glow.value / 2,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Hero(
                                tag: "app_logo",
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // النصوص مع شيمر
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white70,
                              Colors.white
                            ],
                            stops: [0.1, 0.5, 0.9],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            transform:
                                GradientRotation(2 * pi * _bgController.value),
                          ).createShader(rect);
                        },
                        child: Column(
                          children: const [
                            Text(
                              "ABSHIR",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "أبشر - معك خطوة بخطوة",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // شريط تقدم خطي
                  SizedBox(
                    width: 120,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 5500),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 رسام الموجة
class WavePainter extends CustomPainter {
  final double progress;
  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    final path = Path();

    for (double i = 0; i <= size.width; i++) {
      double y = sin((i / size.width * 2 * pi) + (progress * 2 * pi)) * 10 + 20;
      if (i == 0) {
        path.moveTo(i, size.height - y);
      } else {
        path.lineTo(i, size.height - y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}

// 🎨 رسام الجزيئات (Particles)
class ParticlePainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24;
    for (int i = 0; i < 20; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
