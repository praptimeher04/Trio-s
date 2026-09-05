import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class RazorpayPaymentModal extends StatefulWidget {
  static const String razorpayKeyId = 'rzp_test_SEO5AnkQEjW8M8';

  final String productTitle;
  final String amount;
  final String sellerName;
  final String buyerName;
  final String buyerEmail;
  final Function(String paymentId) onPaymentSuccess;

  const RazorpayPaymentModal({
    super.key,
    required this.productTitle,
    required this.amount,
    required this.sellerName,
    this.buyerName = 'Hitija Mhatre',
    this.buyerEmail = 'student@campus.edu',
    required this.onPaymentSuccess,
  });

  static void show(
    BuildContext context, {
    required String productTitle,
    required String amount,
    required String sellerName,
    String buyerName = 'Hitija Mhatre',
    String buyerEmail = 'student@campus.edu',
    required Function(String paymentId) onPaymentSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RazorpayPaymentModal(
        productTitle: productTitle,
        amount: amount,
        sellerName: sellerName,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<RazorpayPaymentModal> createState() => _RazorpayPaymentModalState();
}

class _RazorpayPaymentModalState extends State<RazorpayPaymentModal> {
  // 0: Payment Options, 1: Processing, 2: Success
  int _step = 0;
  String _selectedOption = 'upi';
  String _statusMessage = 'Connecting to Razorpay Secure Server...';
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _fetchRazorpayOrderFromBackend();
  }

  Future<void> _fetchRazorpayOrderFromBackend() async {
    double parsedAmount = 350.0;
    final cleanStr = widget.amount.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanStr.isNotEmpty) {
      parsedAmount = double.tryParse(cleanStr) ?? 350.0;
    }

    final orderRes = await ApiService.createRazorpayOrder(
      amount: parsedAmount,
      productTitle: widget.productTitle,
      buyerName: widget.buyerName,
      buyerEmail: widget.buyerEmail,
      sellerName: widget.sellerName,
    );

    if (mounted) {
      setState(() {
        _orderId = orderRes['orderId']?.toString();
      });
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _step = 1;
      _statusMessage = 'Calling Spring Boot API (http://127.0.0.1:8085/api/payments/create-order)...';
    });

    if (_orderId == null) {
      double parsedAmount = 350.0;
      final cleanStr = widget.amount.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanStr.isNotEmpty) {
        parsedAmount = double.tryParse(cleanStr) ?? 350.0;
      }
      final orderRes = await ApiService.createRazorpayOrder(
        amount: parsedAmount,
        productTitle: widget.productTitle,
        buyerName: widget.buyerName,
        buyerEmail: widget.buyerEmail,
        sellerName: widget.sellerName,
      );
      _orderId = orderRes['orderId']?.toString() ?? 'order_rzp_${DateTime.now().millisecondsSinceEpoch}';
    }

    final String activeOrderId = _orderId ?? 'order_rzp_${DateTime.now().millisecondsSinceEpoch}';
    final String keyId = RazorpayPaymentModal.razorpayKeyId;

    if (!mounted) return;
    setState(() {
      _statusMessage = 'API Order $activeOrderId Created!\nConnecting to Razorpay Gateway (Key: $keyId)...';
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Authorizing transaction with bank...';
      });
    });

    Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';

      double parsedAmount = 350.0;
      final cleanStr = widget.amount.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanStr.isNotEmpty) {
        parsedAmount = double.tryParse(cleanStr) ?? 350.0;
      }

      await ApiService.saveRazorpayPayment(
        paymentId: paymentId,
        orderId: activeOrderId,
        amount: parsedAmount,
        paymentMode: _selectedOption.toUpperCase(),
        buyerName: widget.buyerName,
        buyerEmail: widget.buyerEmail,
      );

      if (!mounted) return;
      setState(() {
        _step = 2;
      });
      Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onPaymentSuccess(paymentId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. TOP BLUE RAZORPAY HEADER BAR (StepOut / Campus Marketplace)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'StepOut',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),

          // 2. MIDDLE CONTENT (Payment Options / Processing / Success)
          Expanded(
            child: _step == 0
                ? _buildPaymentOptionsView()
                : _step == 1
                    ? _buildProcessingView()
                    : _buildSuccessView(),
          ),

          // 3. BOTTOM FIXED BAR (Price + Continue Button)
          if (_step == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.amount,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'View Details',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_up_rounded, size: 14, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- SCREEN 1: OFFICIAL RAZORPAY PAYMENT OPTIONS SCREEN ---
  Widget _buildPaymentOptionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PAGE TITLE
          Text(
            'Payment Options',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // 1. UPI QR CARD
          Text(
            'UPI QR',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // QR CODE GRAPHIC WITH REFRESH BUTTON
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated QR pattern
                      const Icon(Icons.qr_code_2_rounded, size: 90, color: Color(0xFF334155)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'Refresh QR',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // SCAN TEXT & APP LOGOS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan the QR using any UPI App',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildUpiBadge('pop', Colors.deepOrange),
                          _buildUpiBadge('GPay', const Color(0xFF4285F4)),
                          _buildUpiBadge('Cred', Colors.black),
                          _buildUpiBadge('PhonePe', const Color(0xFF5F259F)),
                          _buildUpiBadge('Paytm', const Color(0xFF00BAF2)),
                          _buildUpiBadge('Navi', const Color(0xFF00D09C)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. RECOMMENDED SECTION
          Text(
            'Recommended',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              setState(() => _selectedOption = 'baroda');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6600),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bank of Baroda - Retail Banking Netbanking',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. ALL PAYMENT OPTIONS GROUP
          Text(
            'All Payment Options',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildPaymentOptionRow(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: 'UPI',
                  badges: ['GPay', 'PhonePe', 'Paytm', 'BHIM'],
                  hasExpand: false,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildPaymentOptionRow(
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Cards',
                  badges: ['Visa', 'Mastercard', 'RuPay'],
                  hasExpand: false,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildPaymentOptionRow(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: 'EMI',
                  badges: ['Debit', 'Credit'],
                  hasExpand: false,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildPaymentOptionRow(
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Netbanking',
                  badges: ['HDFC', 'ICICI', 'SBI', 'Axis'],
                  hasExpand: true,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildPaymentOptionRow(
                  icon: Icons.wallet_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Wallet',
                  badges: ['Mobikwik', 'Freecharge'],
                  hasExpand: true,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildPaymentOptionRow(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Pay Later',
                  badges: ['LazyPay', 'ICICI'],
                  hasExpand: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUpiBadge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPaymentOptionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> badges,
    required bool hasExpand,
  }) {
    final isSelected = _selectedOption == title.toLowerCase();

    return InkWell(
      onTap: () {
        setState(() => _selectedOption = title.toLowerCase());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: badges.take(3).map((b) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      b,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Icon(
              hasExpand ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 2: PROCESSING STATE ---
  Widget _buildProcessingView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2563EB),
            strokeWidth: 3.5,
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Razorpay Test Key: ${RazorpayPaymentModal.razorpayKeyId}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- SCREEN 3: SUCCESS CONFIRMATION STATE ---
  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Approved by Razorpay!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Amount Paid: ${widget.amount}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}
