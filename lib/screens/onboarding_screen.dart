import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F4),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Hero illustration
                SizedBox(
                  width: 150,
                  height: 160,
                  child: CustomPaint(painter: _HeartLogoPainter()),
                ),

                const SizedBox(height: 56),

                // Headline
                const Text(
                  'Identify Betel Leaf\nDiseases Instantly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1C2B2B),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Powered by AI — just scan a leaf\nand get results in seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1C2B2B).withOpacity(0.45),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),

                const Spacer(flex: 2),

                // Feature pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FeaturePill(icon: Icons.bolt, label: 'Instant'),
                    const SizedBox(width: 10),
                    _FeaturePill(
                      icon: Icons.verified_outlined,
                      label: 'Accurate',
                    ),
                    const SizedBox(width: 10),
                    _FeaturePill(icon: Icons.spa_outlined, label: 'Plant AI'),
                  ],
                ),

                const SizedBox(height: 36),

                // Get started button — full width, centered
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E6B45).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E8B57), Color(0xFF1E6B45)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E8B57)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2B2B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3DD68C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2;
    final double topY = size.height * 0.18;
    final double peakY = size.height * 0.05;
    final double sideX = size.width * 0.85;
    final double heartBottomY = size.height * 0.72;

    final path = Path();
    path.moveTo(cx, heartBottomY);

    path.cubicTo(
      cx - size.width * 0.05,
      size.height * 0.55,
      size.width * 0.02,
      size.height * 0.38,
      size.width * 0.15,
      topY,
    );
    path.cubicTo(
      size.width * 0.25,
      peakY,
      cx - size.width * 0.02,
      size.height * 0.12,
      cx,
      size.height * 0.28,
    );
    path.cubicTo(
      cx + size.width * 0.02,
      size.height * 0.12,
      size.width * 0.75,
      peakY,
      sideX,
      topY,
    );
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.38,
      cx + size.width * 0.05,
      size.height * 0.55,
      cx,
      heartBottomY,
    );

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(cx, heartBottomY),
      Offset(cx, size.height * 0.92),
      paint,
    );

    final checkPath = Path();
    checkPath.moveTo(cx - 18, size.height * 0.48);
    checkPath.lineTo(cx - 5, size.height * 0.60);
    checkPath.lineTo(cx + 18, size.height * 0.38);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}