import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

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
    {'name': 'Student', 'icon': Icons.school_rounded, 'subtitle': 'Undergrad / Grad'},
    {'name': 'Faculty', 'icon': Icons.badge_rounded, 'subtitle': 'Professors & Staff'},
    {'name': 'Merchant', 'icon': Icons.storefront_rounded, 'subtitle': 'Canteen & Stores'},
    {'name': 'Admin', 'icon': Icons.admin_panel_settings_rounded, 'subtitle': 'Campus Officers'},
  ];

  bool get _has8Chars => _passwordController.text.length >= 8;
  bool get _hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);
  bool get _isPasswordValid => _has8Chars && _hasSpecialChar;
  bool get _doPasswordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
      _confirmPasswordController.text.isNotEmpty;

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().contains('@') &&
      _isPasswordValid &&
      _doPasswordsMatch &&
      _acceptTerms &&
      !_isLoading;

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
    if (_isFormValid && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call to backend
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account registered! Welcome to Campus Ecosystem.'),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userEmail: _emailController.text,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 5,
                shadowColor: Colors.black.withAlpha(25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Hero Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(45),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Join Campus Ecosystem',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Create your digital financial wallet & campus pass',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Body
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // SECTION 1: ROLE SELECTION
                              _buildSectionTitle(
                                icon: Icons.badge_outlined,
                                title: 'Select Campus Role',
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2.2,
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
                                            ? AppColors.primary.withAlpha(15)
                                            : AppColors.inputBackground,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : AppColors.inputBorder,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            role['icon'] as IconData,
                                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  role['name'] as String,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  role['subtitle'] as String,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9.5,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primary,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 22),

                              // SECTION 2: PERSONAL IDENTITY
                              _buildSectionTitle(
                                icon: Icons.person_outline_rounded,
                                title: 'Personal Identity',
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                label: 'Full Name',
                                hintText: 'e.g. Rahul Sharma',
                                prefixIcon: Icons.account_circle_outlined,
                                controller: _nameController,
                                onChanged: (val) => setState(() {}),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Campus Email',
                                hintText: 'student@campus.edu',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (val) => setState(() {}),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your campus email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // SECTION 3: ACCOUNT SECURITY
                              _buildSectionTitle(
                                icon: Icons.lock_outline_rounded,
                                title: 'Password & Security',
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                label: 'Password',
                                hintText: '••••••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                controller: _passwordController,
                                isPassword: true,
                                isPasswordVisible: _isPasswordVisible,
                                errorText: _passwordErrorText,
                                onChanged: (val) => setState(() {}),
                                onTogglePassword: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
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
                              ),
                              const SizedBox(height: 10),

                              // Password Rules Checklist
                              _buildRulesChecklist(),
                              const SizedBox(height: 16),

                              // Confirm Password Input
                              CustomTextField(
                                label: 'Confirm Password',
                                hintText: 'Re-enter password to confirm',
                                prefixIcon: Icons.lock_reset_rounded,
                                controller: _confirmPasswordController,
                                isPassword: true,
                                isPasswordVisible: _isConfirmPasswordVisible,
                                errorText: _confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch
                                    ? 'Passwords do not match'
                                    : null,
                                onChanged: (val) => setState(() {}),
                                onTogglePassword: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Terms & Conditions Checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: _acceptTerms,
                                      activeColor: AppColors.primary,
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I accept Campus Terms & Privacy Policy',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Complete Registration Submit Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: _isFormValid
                                      ? AppColors.primaryGradient
                                      : const LinearGradient(
                                          colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _isFormValid
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withAlpha(80),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isFormValid ? _handleRegister : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
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
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: _isFormValid ? Colors.white : Colors.white70,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bottom Divider & Switch to Login
                              const Divider(color: AppColors.surfaceBorder, height: 1),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already registered? ',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
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
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRulesChecklist() {
    final hasTyped = _passwordController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTyped && !_isPasswordValid
              ? AppColors.error.withAlpha(120)
              : AppColors.inputBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Rules:',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasTyped && !_isPasswordValid ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildRuleItem('At least 8 characters long', isMet: _has8Chars, hasTyped: hasTyped),
          const SizedBox(height: 3),
          _buildRuleItem(r'Special character (!@#$%^&*)', isMet: _hasSpecialChar, hasTyped: hasTyped),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String label, {required bool isMet, required bool hasTyped}) {
    final Color color = isMet
        ? AppColors.primary
        : (hasTyped ? AppColors.error : AppColors.textSecondary);

    final IconData icon = isMet
        ? Icons.check_circle_rounded
        : (hasTyped ? Icons.cancel_rounded : Icons.radio_button_unchecked_rounded);

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: isMet || (hasTyped && !isMet) ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
