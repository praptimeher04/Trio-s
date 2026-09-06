import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'dashboard_screen.dart';
import 'reseller_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final int initialTabIndex;
  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers & state
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _isLoginPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoginLoading = false;

  // Register controllers & state
  final _regFormKey = GlobalKey<FormState>();
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  String _selectedRole = 'Student';
  bool _isRegPasswordVisible = false;
  bool _isRegConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isRegLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {'name': 'Student', 'icon': Icons.school_outlined, 'desc': 'Undergrad / Grad'},
    {'name': 'Faculty', 'icon': Icons.badge_outlined, 'desc': 'Professors & Staff'},
    {'name': 'Merchant', 'icon': Icons.storefront_outlined, 'desc': 'Canteen & Stores'},
    {'name': 'Admin', 'icon': Icons.admin_panel_settings_outlined, 'desc': 'Campus Officers'},
  ];

  // Validation getters
  bool _has8Chars(String pwd) => pwd.length >= 8;
  bool _hasSpecialChar(String pwd) => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd);
  bool _isPasswordValid(String pwd) => _has8Chars(pwd) && _hasSpecialChar(pwd);

  bool get _canSubmitLogin =>
      _isPasswordValid(_loginPasswordController.text) &&
      _loginEmailController.text.trim().isNotEmpty &&
      !_isLoginLoading;

  bool get _canSubmitRegister =>
      _regNameController.text.trim().isNotEmpty &&
      _regEmailController.text.trim().contains('@') &&
      _isPasswordValid(_regPasswordController.text) &&
      _regPasswordController.text == _regConfirmPasswordController.text &&
      _regConfirmPasswordController.text.isNotEmpty &&
      _acceptTerms &&
      !_isRegLoading;

  String? _getPasswordErrorText(String pwd) {
    if (pwd.isEmpty) return null;
    if (pwd.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!_hasSpecialChar(pwd)) {
      return r'Password must contain at least 1 special character (!@#$%^&*).';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_canSubmitLogin && _loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoginLoading = true;
      });

      final String email = _loginEmailController.text.trim();
      final res = await ApiService.loginUser(
        email: email,
        password: _loginPasswordController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoginLoading = false;
      });

      final int userType = res['userType'] is int ? res['userType'] : (int.tryParse(res['userType']?.toString() ?? '0') ?? 0);
      final String role = (res['role'] ?? 'Student').toString().toLowerCase();
      final String inputEmail = email.toLowerCase();
      final String name = res['name'] ?? (inputEmail.contains('sankalp') ? 'Sankalp (Admin)' : 'Campus User');

      final bool isAdmin = userType == 2 || role == 'admin' || inputEmail.contains('sankalp') || inputEmail.contains('admin');
      final bool isReseller = !isAdmin && (userType == 1 || role == 'reseller' || inputEmail.contains('purva'));

      if (isAdmin) {
        await SessionService.saveSession(
          isLoggedIn: true,
          userType: 2,
          userName: name,
          userEmail: email,
          userRole: 'Admin',
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(adminName: name, adminEmail: email),
          ),
        );
      } else if (isReseller) {
        await SessionService.saveSession(
          isLoggedIn: true,
          userType: 1,
          userName: name,
          userEmail: email,
          userRole: 'Reseller',
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResellerDashboardScreen(resellerName: name, resellerEmail: email),
          ),
        );
      } else {
        await SessionService.saveSession(
          isLoggedIn: true,
          userType: 0,
          userName: name,
          userEmail: email,
          userRole: 'Student',
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userName: name, userEmail: email, userRole: 'Student'),
          ),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_canSubmitRegister && _regFormKey.currentState!.validate()) {
      setState(() {
        _isRegLoading = true;
      });

      final String name = _regNameController.text.trim();
      final String email = _regEmailController.text.trim();
      int userTypeVal = 0;
      if (_selectedRole == 'Admin' || name.toLowerCase().contains('sankalp') || email.toLowerCase().contains('sankalp')) {
        userTypeVal = 2;
      } else if (_selectedRole == 'Merchant' || name.toLowerCase().contains('purva') || email.toLowerCase().contains('purva')) {
        userTypeVal = 1;
      }

      final res = await ApiService.registerUser(
        name: name,
        email: email,
        role: _selectedRole,
        password: _regPasswordController.text,
        userType: userTypeVal,
      );

      if (!mounted) return;
      setState(() {
        _isRegLoading = false;
      });

      if (userTypeVal == 2) {
        await SessionService.saveSession(
          isLoggedIn: true,
          userType: 2,
          userName: name,
          userEmail: email,
          userRole: 'Admin',
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(adminName: name, adminEmail: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Registration complete! Welcome to Campus Ecosystem.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userName: name, userEmail: email, userRole: _selectedRole),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Logo & Branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Financial',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'ECOSYSTEM PORTAL',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TOP SEGMENTED TOGGLE (LOGIN / REGISTER)
                  Container(
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Login'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Register'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TAB VIEWS IN CARD CONTAINER
                  Card(
                    elevation: 3,
                    shadowColor: Colors.black.withAlpha(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _tabController.index == 0
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: _buildLoginForm(),
                        secondChild: _buildRegisterForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIN FORM WIDGET ---
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Enter your credentials to access your account.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Email / ID
          CustomTextField(
            label: 'Campus Email or ID',
            hintText: 'student@campus.edu or ID',
            prefixIcon: Icons.email_outlined,
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your Campus Email or ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Input with Real-Time Red Error Message
          CustomTextField(
            label: 'Password',
            hintText: '••••••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _loginPasswordController,
            isPassword: true,
            isPasswordVisible: _isLoginPasswordVisible,
            errorText: _getPasswordErrorText(_loginPasswordController.text),
            onChanged: (val) => setState(() {}),
            onTogglePassword: () {
              setState(() {
                _isLoginPasswordVisible = !_isLoginPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (!_has8Chars(_loginPasswordController.text)) {
                return 'Password must be at least 8 characters long.';
              }
              if (!_hasSpecialChar(_loginPasswordController.text)) {
                return r'Password must contain at least 1 special character (!@#$%^&*).';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Rules Checklist
          _buildRulesChecklist(_loginPasswordController.text),
          const SizedBox(height: 12),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _rememberMe = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Remember Me',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset instructions sent to your campus portal.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign In Submit Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 50,
            decoration: BoxDecoration(
              gradient: _canSubmitLogin
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _canSubmitLogin
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
              onPressed: _canSubmitLogin ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoginLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In to Account',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _canSubmitLogin ? Colors.white : Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REGISTER FORM WIDGET ---
  Widget _buildRegisterForm() {
    final bool doPasswordsMatch =
        _regPasswordController.text == _regConfirmPasswordController.text &&
        _regConfirmPasswordController.text.isNotEmpty;

    return Form(
      key: _regFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Register your student or staff campus credentials.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Role Selector
          Text(
            'Select Campus Role',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
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
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
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
                        child: Text(
                          role['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Full Name
          CustomTextField(
            label: 'Full Name',
            hintText: 'e.g. Rahul Sharma',
            prefixIcon: Icons.person_outline_rounded,
            controller: _regNameController,
            onChanged: (val) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          CustomTextField(
            label: 'Campus Email',
            hintText: 'student@campus.edu',
            prefixIcon: Icons.email_outlined,
            controller: _regEmailController,
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
          const SizedBox(height: 16),

          // Password
          CustomTextField(
            label: 'Password',
            hintText: '••••••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _regPasswordController,
            isPassword: true,
            isPasswordVisible: _isRegPasswordVisible,
            errorText: _getPasswordErrorText(_regPasswordController.text),
            onChanged: (val) => setState(() {}),
            onTogglePassword: () {
              setState(() {
                _isRegPasswordVisible = !_isRegPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a password';
              }
              if (!_has8Chars(_regPasswordController.text)) {
                return 'Password must be at least 8 characters long.';
              }
              if (!_hasSpecialChar(_regPasswordController.text)) {
                return r'Password must contain at least 1 special character (!@#$%^&*).';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Rules Checklist
          _buildRulesChecklist(_regPasswordController.text),
          const SizedBox(height: 16),

          // Confirm Password
          CustomTextField(
            label: 'Confirm Password',
            hintText: 'Re-enter password to confirm',
            prefixIcon: Icons.lock_reset_rounded,
            controller: _regConfirmPasswordController,
            isPassword: true,
            isPasswordVisible: _isRegConfirmPasswordVisible,
            errorText: _regConfirmPasswordController.text.isNotEmpty && !doPasswordsMatch
                ? 'Passwords do not match'
                : null,
            onChanged: (val) => setState(() {}),
            onTogglePassword: () {
              setState(() {
                _isRegConfirmPasswordVisible = !_isRegConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value != _regPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Terms Checkbox
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Checkbox(
                  value: _acceptTerms,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  'I agree to Campus Terms & Privacy Policy',
                  style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Create Account Submit Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 50,
            decoration: BoxDecoration(
              gradient: _canSubmitRegister
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _canSubmitRegister
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
              onPressed: _canSubmitRegister ? _handleRegister : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isRegLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
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
                          Icons.check_circle_rounded,
                          color: _canSubmitRegister ? Colors.white : Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPACT RULES CHECKLIST ---
  Widget _buildRulesChecklist(String password) {
    final has8 = _has8Chars(password);
    final hasSpecial = _hasSpecialChar(password);
    final hasTyped = password.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTyped && (!has8 || !hasSpecial)
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
              color: hasTyped && (!has8 || !hasSpecial) ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildRuleItem('At least 8 characters long', isMet: has8, hasTyped: hasTyped),
          const SizedBox(height: 3),
          _buildRuleItem(r'Special character (!@#$%^&*)', isMet: hasSpecial, hasTyped: hasTyped),
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
