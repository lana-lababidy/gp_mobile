import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  final Color _brand = const Color(0xFF0A2A6C);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

    _c.forward();

    // انتقال للهوم
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomeScreen(initialIndex: 0),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _brand;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // موجة خفيفة بالأسفل
            const _BottomWave(),

            // المحتوى الأساسي
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ شعار من assets + errorBuilder
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 3.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/abshir_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('🚨 خطأ تحميل الصورة: $error');
                                return const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // اسم التطبيق
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 8, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOut,
                        builder: (_, value, __) {
                          return Text(
                            'ABSHIR',
                            style: TextStyle(
                              letterSpacing: value,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'أبشر',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // خط تقدم رفيع
                      _ProgressLine(color: Colors.white.withValues(alpha: 0.9)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// خط تقدم رفيع متحرك
class _ProgressLine extends StatefulWidget {
  final Color color;
  const _ProgressLine({required this.color});

  @override
  State<_ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends State<_ProgressLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final w =
            MediaQuery.of(context).size.width * (0.25 + 0.55 * _anim.value);
        return Container(
          width: w,
          height: 4,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      },
    );
  }
}

// موجة زخرفية بأسفل الشاشة
class _BottomWave extends StatelessWidget {
  const _BottomWave();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22000000),
                Color(0x11000000),
                Color(0x00000000),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, 0);
    p.lineTo(0, size.height * .4);
    p.quadraticBezierTo(
      size.width * .25,
      size.height * .65,
      size.width * .5,
      size.height * .4,
    );
    p.quadraticBezierTo(
      size.width * .75,
      size.height * .15,
      size.width,
      size.height * .35,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
