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

  // نقاط الجزيئات تتولّد مرة واحدة
  late final List<Offset> _particles;

  @override
  void initState() {
    super.initState();

    // أنيميشن الشعار
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // أنيميشن النصوص
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // توهّج الشعار
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0, end: 15).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // خلفية متدرجة متحركة
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    // نقاط Particles ثابتة
    final rnd = Random(42);
    _particles = List.generate(
      20,
      (_) => Offset(rnd.nextDouble(), rnd.nextDouble()),
    );

    // تشغيل الأنيميشنات
    _logoController.forward().then((_) => _textController.forward());

    // الانتقال بعد 5.5 ثانية — بدون const
    Timer(const Duration(milliseconds: 5500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PhoneScreen()),
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
            // الخلفية: Particles
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlePainterStatic(_particles),
              ),
            ),

            // الموجة بأسفل الشاشة
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 100,
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (_, __) => CustomPaint(
                    painter: WavePainter(_bgController.value),
                  ),
                ),
              ),
            ),

            // المحتوى الأساسي
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الشعار: دائري + إطار + ظل + توهّج
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
                              color: Colors.white.withValues(alpha: 0.10),
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 4,
                              ),
                              boxShadow: [
                                // ظل ناعم
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                                // توهّج أبيض متغيّر
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  blurRadius: _glow.value,
                                  spreadRadius: _glow.value / 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Hero(
                                tag: 'app_logo',
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/abshir_logo.png', // عدّل الاسم إذا لزم
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // النصوص + شيمر
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) {
                          return LinearGradient(
                            colors: const [
                              Colors.white,
                              Colors.white70,
                              Colors.white
                            ],
                            stops: const [0.1, 0.5, 0.9],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            transform:
                                GradientRotation(2 * pi * _bgController.value),
                          ).createShader(rect);
                        },
                        child: const Column(
                          children: [
                            Text(
                              'ABSHIR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'أبشر - معك خطوة بخطوة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // شريط تقدم
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

/* 🎨 رسام الموجة */
class WavePainter extends CustomPainter {
  final double progress;
  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final path = Path();

    for (double i = 0; i <= size.width; i++) {
      final y = sin((i / size.width * 2 * pi) + (progress * 2 * pi)) * 10 + 20;
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
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/* 🎨 رسام الجزيئات (Particles) بنقاط ثابتة */
class ParticlePainterStatic extends CustomPainter {
  final List<Offset> points01; // نقاط بنسبة (0..1) من الحجم
  const ParticlePainterStatic(this.points01);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24; // ثابتة، تمام
    for (final p in points01) {
      final dx = p.dx * size.width;
      final dy = p.dy * size.height;
      canvas.drawCircle(Offset(dx, dy), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
