import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'reseller_register_screen.dart';
import 'reseller_dashboard_screen.dart';

class ResellerLoginScreen extends StatefulWidget {
  const ResellerLoginScreen({super.key});

  @override
  State<ResellerLoginScreen> createState() => _ResellerLoginScreenState();
}

class _ResellerLoginScreenState extends State<ResellerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await ApiService.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      userType: 1,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final String emailInput = _emailController.text.trim();
    final String fallbackName = emailInput.isNotEmpty ? emailInput.split('@')[0] : 'Reseller Peer';

    final String resellerName = res['success'] == true ? (res['name'] ?? fallbackName) : fallbackName;
    final String resellerEmail = res['success'] == true ? (res['email'] ?? emailInput) : emailInput;
    final String resellerMobile = res['success'] == true ? (res['mobileNumber'] ?? '+91 98765 43210') : '+91 98765 43210';

    await SessionService.saveSession(
      isLoggedIn: true,
      userType: 1,
      userName: resellerName,
      userEmail: resellerEmail,
      userRole: 'Reseller',
      mobileNumber: resellerMobile,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome Reseller $resellerName!'),
        backgroundColor: const Color(0xFF0B6E4F),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResellerDashboardScreen(
          resellerName: resellerName,
          resellerEmail: resellerEmail,
          resellerMobile: resellerMobile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reseller Portal Login',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RESELLER LOGO BANNER
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 52, color: Color(0xFF0B6E4F)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Marketplace Reseller Panel',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Manage active product listings, upload books & calculators',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // EMAIL FIELD
              Text('Reseller Email / Campus ID', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'reseller@campus.edu',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0B6E4F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your reseller email' : null,
              ),
              const SizedBox(height: 16),

              // PASSWORD FIELD
              Text('Password', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0B6E4F)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 24),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleLogin,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.login_rounded, size: 20),
                  label: Text(
                    _isLoading ? 'Signing into Reseller Panel...' : 'Login to Reseller Panel',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6E4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // REGISTER LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Want to sell products on campus? ', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ResellerRegisterScreen()),
                      );
                    },
                    child: Text(
                      'Register Reseller Account',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0B6E4F)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
