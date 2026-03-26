import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F4), // light mint background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SVG-style logo drawn with CustomPaint
                SizedBox(
                  width: 120,
                  height: 130,
                  child: CustomPaint(painter: _GreenScanLogoPainter()),
                ),

                const SizedBox(height: 32),

                // GREENSCAN title
                const Text(
                  'G R E E N S C A N',
                  style: TextStyle(
                    color: Color(0xFF1C2B2B),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'PRECISION HEALTH TECHNOLOGY',
                  style: TextStyle(
                    color: Color(0xFF4CAF82),
                    fontSize: 10,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreenScanLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3DD68C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2;

    // Heart shape path
    final path = Path();

    // Heart: starts at bottom tip, goes up right side, over top right curve,
    // across top left curve, down left side, back to bottom tip
    final double topY = size.height * 0.18;
    final double midX = cx;
    final double peakY = size.height * 0.05;
    final double sideX = size.width * 0.85;
    final double heartBottomY = size.height * 0.72;

    // Start at bottom point of heart
    path.moveTo(midX, heartBottomY);

    // Left side up to top-left curve
    path.cubicTo(
      midX - size.width * 0.05,
      size.height * 0.55,
      size.width * 0.02,
      size.height * 0.38,
      size.width * 0.15,
      topY,
    );

    // Top-left arc
    path.cubicTo(
      size.width * 0.25,
      peakY,
      midX - size.width * 0.02,
      size.height * 0.12,
      midX,
      size.height * 0.28,
    );

    // Top-right arc
    path.cubicTo(
      midX + size.width * 0.02,
      size.height * 0.12,
      size.width * 0.75,
      peakY,
      sideX,
      topY,
    );

    // Right side down to bottom point
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.38,
      midX + size.width * 0.05,
      size.height * 0.55,
      midX,
      heartBottomY,
    );

    canvas.drawPath(path, paint);

    // Stem going down from heart bottom
    canvas.drawLine(
      Offset(midX, heartBottomY),
      Offset(midX, size.height * 0.92),
      paint,
    );

    // Checkmark inside heart
    final checkPaint = Paint()
      ..color = const Color(0xFF3DD68C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(cx - 14, size.height * 0.48);
    checkPath.lineTo(cx - 4, size.height * 0.58);
    checkPath.lineTo(cx + 14, size.height * 0.38);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}