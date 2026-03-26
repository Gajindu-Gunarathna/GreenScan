import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedDistrict;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── BACKEND — DO NOT TOUCH ──
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your district.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      password: _passwordController.text,
      address: _addressController.text,
      city: _cityController.text,
      district: _selectedDistrict!,
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
      fillColor: Colors.white,
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: const TextStyle(
            color: Color(0xFF1C2B2B),
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: _inputDecoration(hintText: hint, prefixIcon: prefixIcon),
          validator: validator,
        ),
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
                  const SizedBox(height: 50),

                  SizedBox(
                    width: 130,
                    height: 140,
                    child: CustomPaint(painter: _HeartLogoPainter()),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1C2B2B),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Create an account to track plant health,\nget alerts, and expert guidance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1C2B2B).withOpacity(0.5),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    enabled: !isLoading,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ),

                  _buildField(
                    controller: _phoneController,
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Phone is required' : null,
                  ),

                  _buildField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
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
                        decoration: _inputDecoration(
                          hintText: 'Create a password',
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
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  _buildField(
                    controller: _addressController,
                    hint: 'Enter your address',
                    enabled: !isLoading,
                    prefixIcon: Icons.home_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Address is required' : null,
                  ),

                  _buildField(
                    controller: _cityController,
                    hint: 'Enter your city',
                    enabled: !isLoading,
                    prefixIcon: Icons.location_city_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'City is required' : null,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: _inputDecoration(
                          hintText: 'Select your district',
                          prefixIcon: Icons.map_outlined,
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF1C2B2B),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7B8883),
                        ),
                        items: AppConstants.sriLankaDistricts
                            .map(
                              (d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(d),
                              ),
                            )
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedDistrict = value;
                                });
                              },
                        validator: (v) =>
                            v == null ? 'Please select a district' : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

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
                      onPressed: isLoading ? null : _register,
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
                                  'Register Now',
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

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF1C2B2B).withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF2E8B57),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
