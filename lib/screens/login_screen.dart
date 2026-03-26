import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first, then tap Forgot Password.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().sendPasswordReset(
        _emailController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF8A9792),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF5F6F68), size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8E5DF), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF2E8B57), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.state == AuthState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  SizedBox(
                    width: 130,
                    height: 140,
                    child: CustomPaint(painter: _HeartLogoPainter()),
                  ),

                  const SizedBox(height: 30),

                  // Heading
                  const Text(
                    'Welcome back!\nGlad to see you, Again!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1C2B2B),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.28,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      style: const TextStyle(
                        color: Color(0xFF1C2B2B),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      style: const TextStyle(
                        color: Color(0xFF1C2B2B),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF7B8883),
                            size: 21,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => context.go('/forgot-password'),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF37433F),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E6B45).withOpacity(0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2F925B), Color(0xFF1E6B45)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Register link section
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: const Color(0xFF1C2B2B).withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  /* MODIFICATION: Removed the Row and the 'Admin' link. 
                     The 'Register' link is now a standalone GestureDetector to keep it centered.
                  */
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color(0xFF2E8B57),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
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
    checkPath.moveTo(cx - 16, size.height * 0.48);
    checkPath.lineTo(cx - 4, size.height * 0.60);
    checkPath.lineTo(cx + 16, size.height * 0.38);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
