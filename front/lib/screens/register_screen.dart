import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Student';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {'name': 'Student', 'icon': Icons.school_rounded, 'subtitle': 'Undergrad / ..'},
    {'name': 'Faculty', 'icon': Icons.badge_rounded, 'subtitle': 'Professors & Staff'},
    {'name': 'Merchant', 'icon': Icons.storefront_rounded, 'subtitle': 'Canteen & Stores'},
    {'name': 'Admin', 'icon': Icons.admin_panel_settings_rounded, 'subtitle': 'Campus Officers'},
  ];

  bool get _has8Chars => _passwordController.text.length >= 8;
  bool get _hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);
  bool get _doPasswordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
      _confirmPasswordController.text.isNotEmpty;

  String? get _passwordErrorText {
    final password = _passwordController.text;
    if (password.isEmpty) return null;
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!_hasSpecialChar) {
      return r'Password must contain at least 1 special character (!@#$%^&*).';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Campus Terms & Privacy Policy.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // API Call to Spring Boot Auth Registration Endpoint
      final result = await ApiService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          final userIdStr = result['userId'] != null ? ' (Database User ID: #${result['userId']})' : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 ${result['message'] ?? 'User registered in database successfully!'}$userIdStr'),
              backgroundColor: const Color(0xFF059669),
              duration: const Duration(seconds: 4),
            ),
          );

          // Redirect directly to LoginScreen after successful registration
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                initialEmail: _emailController.text.trim(),
                registeredName: _nameController.text.trim(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed.'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final labelTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final inputBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final mutedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 440),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(36.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BEGIN: HeaderHeroSection
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 48,
                            bottom: 36,
                            left: 24,
                            right: 24,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF059669), // brand-600
                                Color(0xFF10B981), // brand-500
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(42),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Circular User/Add-Person Icon Badge
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Title
                              Text(
                                'Join Campus Ecosystem',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              // Subtitle
                              Text(
                                'Create your digital financial wallet & campus pass',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFECFDF5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Ambient decorative glow rings (Top Right)
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Ambient decorative glow rings (Bottom Left)
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF34D399).withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // END: HeaderHeroSection

                    // BEGIN: MainRegistrationForm
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==============================================
                            // SECTION 1: ROLE SELECTION
                            // ==============================================
                            _buildSectionTitle(
                              icon: Icons.menu_book_rounded,
                              title: 'Select Campus Role',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.3,
                              ),
                              itemCount: _roles.length,
                              itemBuilder: (context, index) {
                                final role = _roles[index];
                                final isSelected = _selectedRole == role['name'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = role['name'];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFECFDF5))
                                          : cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF10B981)
                                            : borderColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                role['icon'] as IconData,
                                                color: isSelected
                                                    ? const Color(0xFF059669)
                                                    : mutedTextColor,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    role['name'] as String,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected
                                                          ? const Color(0xFF047857)
                                                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    role['subtitle'] as String,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9.5,
                                                      color: mutedTextColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isSelected)
                                          const Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Icon(
                                              Icons.check_circle_rounded,
                                              color: Color(0xFF059669),
                                              size: 15,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // ==============================================
                            // SECTION 2: PERSONAL IDENTITY
                            // ==============================================
                            _buildSectionTitle(
                              icon: Icons.person_outline_rounded,
                              title: 'Personal Identity',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),

                            // Full Name Field
                            Text(
                              'Full Name',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: labelTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              onChanged: (val) => setState(() {}),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g. Hitija Mhatre',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: const Icon(
                                  Icons.account_circle_outlined,
                                  color: Color(0xFF059669),
                                  size: 20,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campus Email Field
                            Text(
                              'Campus Email',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: labelTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => setState(() {}),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your campus email';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'hitija@campus.edu',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: Color(0xFF059669),
                                  size: 20,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ==============================================
                            // SECTION 3: PASSWORD & SECURITY
                            // ==============================================
                            _buildSectionTitle(
                              icon: Icons.lock_outline_rounded,
                              title: 'Password & Security',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),

                            // Password Field
                            Text(
                              'Password',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: labelTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              onChanged: (val) => setState(() {}),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                letterSpacing: _isPasswordVisible ? 0 : 2.0,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (!_has8Chars) {
                                  return 'Password must be at least 8 characters long.';
                                }
                                if (!_hasSpecialChar) {
                                  return r'Password must contain at least 1 special character (!@#$%^&*).';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: '••••••••••••',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF059669),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _passwordErrorText != null
                                        ? const Color(0xFFDC2626)
                                        : borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _passwordErrorText != null
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (_passwordErrorText != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  _passwordErrorText!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Password Rules Box
                            _buildRulesBox(isDark),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            Text(
                              'Confirm Password',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: labelTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              onChanged: (val) => setState(() {}),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                letterSpacing: _isConfirmPasswordVisible ? 0 : 2.0,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Re-enter password to confirm',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: Color(0xFF059669),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch
                                        ? const Color(0xFFDC2626)
                                        : borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (_confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  'Passwords do not match',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // ==============================================
                            // SECTION 4: TERMS & SUBMIT
                            // ==============================================
                            Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    activeColor: const Color(0xFF059669),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _acceptTerms = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'I accept Campus Terms & Privacy Policy',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Primary Registration CTA Button
                            GestureDetector(
                              onTap: !_isLoading ? _handleRegister : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: !_isLoading
                                      ? const Color(0xFF047857) // brand-700 / emerald-700
                                      : const Color(0xFF94A3B8),
                                  borderRadius: BorderRadius.circular(30.0),
                                  boxShadow: !_isLoading
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF059669).withValues(alpha: 0.35),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Complete Registration',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider & Sign In Navigation
                            Divider(color: borderColor, height: 1),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already registered? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: mutedTextColor,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In Here',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF047857),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // END: MainRegistrationForm
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF059669)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildRulesBox(bool isDark) {
    final hasTyped = _passwordController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Rules:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleRow(
            label: 'At least 8 characters long',
            isMet: _has8Chars,
            hasTyped: hasTyped,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildRuleRow(
            label: r'Special character (!@#$%^&*)',
            isMet: _hasSpecialChar,
            hasTyped: hasTyped,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow({
    required String label,
    required bool isMet,
    required bool hasTyped,
    required bool isDark,
  }) {
    Color iconColor;
    Color textColor;
    IconData icon;

    if (isMet) {
      iconColor = const Color(0xFF059669);
      textColor = isDark ? Colors.white : const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
    } else if (hasTyped) {
      iconColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFDC2626);
      icon = Icons.cancel_rounded;
    } else {
      iconColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

