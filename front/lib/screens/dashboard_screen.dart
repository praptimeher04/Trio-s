import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_modal.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const DashboardScreen({
    super.key,
    this.userName = 'Hitija Mhatre',
    required this.userEmail,
    this.userRole = 'Student',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentBottomNavIndex = 0;
  int _unreadNotifications = 3;

  String get _displayName {
    if (widget.userName.trim().isNotEmpty) {
      return widget.userName.trim();
    }
    if (widget.userEmail.trim().isNotEmpty && widget.userEmail.contains('@')) {
      return widget.userEmail.split('@')[0];
    }
    return 'Hitija Mhatre';
  }

  String get _initials {
    final name = _displayName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // 3 Clean Tabs: Home, Marketplace, Profile
    final List<Widget> pages = [
      _buildHomeDashboardView(),
      _buildMarketplaceView(),
      ProfileScreen(
        userName: _displayName,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(15),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _currentBottomNavIndex = 2; // Switch to Profile tab
            });
          },
          child: Row(
            children: [
              // REAL USER AVATAR & INITIALS
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.userRole} • #2026-CS-892',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // NOTIFICATION BELL WITH BADGE COUNTER
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 26),
                onPressed: () => _showNotificationsModal(context),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Logout Action
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // SCREEN BODY (Selected Tab View)
      body: pages[_currentBottomNavIndex],

      // MAIN BOTTOM NAVIGATION BAR (3 Clean Tabs)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: HOME DASHBOARD VIEW ---
  Widget _buildHomeDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP SECTION: Wallet Card
          _buildWalletBalanceCard(),
          const SizedBox(height: 28),

          // MIDDLE SECTION: Financial Summary (Total Savings & Total Earnings)
          Text(
            'Financial Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildMiddleMetricsGrid(),
          const SizedBox(height: 28),

          // MAIN FEATURES GRID (Marketplace, Wallet, Savings, Fee Tracker)
          Text(
            'Main Campus Services',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildMainFeatureGrid(context),
        ],
      ),
    );
  }

  // --- TAB 2: MARKETPLACE VIEW ---
  Widget _buildMarketplaceView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campus Marketplace',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          Text(
            'Buy and sell books, equipment, and gear with verified campus peers.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildMarketplaceTile('📚 Data Structures & Algorithms Textbook', '₹350', 'Sneha • CSE Dept'),
          _buildMarketplaceTile('🚲 Hero Campus Bicycle (1-Year Used)', '₹1,800', 'Vikrant • Mech Dept'),
          _buildMarketplaceTile('⚡ Scientific Calculator Casio FX-991EX', '₹600', 'Ankit • ECE Dept'),
          _buildMarketplaceTile('🧪 Engineering Lab Coat & Safety Goggles', '₹250', 'Pooja • BioTech Dept'),
        ],
      ),
    );
  }

  // --- WALLET BALANCE CARD ---
  Widget _buildWalletBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(70),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Campus Digital Wallet',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE PASS',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹14,500.00',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWalletModal(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Money'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWalletModal(context),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Transfer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SUMMARY METRICS GRID (Total Savings & Total Earnings) ---
  Widget _buildMiddleMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricCard('Total Savings', '₹8,250.00', '+12% this month', Icons.savings_rounded, const Color(0xFF10B981)),
        _buildMetricCard('Total Earnings', '₹12,400.00', 'Stipends & Grants', Icons.trending_up_rounded, const Color(0xFF059669)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withAlpha(25), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10.5, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- MAIN FEATURE GRID (Marketplace, Wallet, Savings, Fee Tracker) ---
  Widget _buildMainFeatureGrid(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Marketplace',
        'subtitle': 'Buy & Sell Textbooks',
        'icon': Icons.storefront_rounded,
        'color': const Color(0xFF059669),
        'onTap': () => setState(() => _currentBottomNavIndex = 1),
      },
      {
        'title': 'Wallet',
        'subtitle': 'Manage Accounts & Cards',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => _openWalletModal(context),
      },
      {
        'title': 'Savings',
        'subtitle': 'Goals & Piggy Bank',
        'icon': Icons.savings_rounded,
        'color': const Color(0xFFEC4899),
        'onTap': () => _openSavingsModal(context),
      },
      {
        'title': 'Fee Tracker',
        'subtitle': 'Tuition & Hostel Fees',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF0284C7),
        'onTap': () => _openFeeTrackerModal(context),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feat = features[index];
        final Color color = feat['color'] as Color;
        return InkWell(
          onTap: feat['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                  child: Icon(feat['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(feat['title'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(feat['subtitle'] as String, style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODALS & HELPER TILES ---
  void _showNotificationsModal(BuildContext context) {
    setState(() {
      _unreadNotifications = 0;
    });
    FeatureModal.show(
      context,
      title: 'Campus Notifications',
      icon: Icons.notifications_rounded,
      accentColor: AppColors.primary,
      child: Column(
        children: [
          _buildNotificationItem('💰 Stipend Credited', 'Research Stipend of ₹5,000 deposited.', '10 min ago'),
          _buildNotificationItem('🎓 Tuition Fee Reminder', 'Semester 5 Tuition due in 12 days.', '2 hours ago'),
          _buildNotificationItem('🛒 Marketplace Inquiry', 'Someone interested in your Cycle listing.', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTile(String title, String price, String seller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: Color(0xFF059669), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                Text(seller, style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
        ],
      ),
    );
  }

  void _openWalletModal(BuildContext context) {
    FeatureModal.show(
      context,
      title: 'Campus Wallet & UPI',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance: ₹14,500.00', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildWalletActionRow(Icons.add_circle_outline_rounded, 'Recharge Wallet via UPI', 'Add funds instantly'),
          _buildWalletActionRow(Icons.qr_code_scanner_rounded, 'Scan QR at Canteen', 'Instant tap & pay'),
          _buildWalletActionRow(Icons.swap_horiz_rounded, 'Transfer to Bank Account', 'Zero fee transfer'),
        ],
      ),
    );
  }

  Widget _buildWalletActionRow(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
              Text(sub, style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _openSavingsModal(BuildContext context) {
    FeatureModal.show(
      context,
      title: 'Campus Savings & Piggy Bank',
      icon: Icons.savings_rounded,
      accentColor: const Color(0xFFEC4899),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Goals Progress:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _buildSavingsGoal('💻 New Laptop Fund', '₹8,250 / ₹45,000', 0.18),
          _buildSavingsGoal('🎓 Semester Excursion Trip', '₹3,500 / ₹5,000', 0.70),
        ],
      ),
    );
  }

  Widget _buildSavingsGoal(String title, String amount, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(amount, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFEC4899))),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.inputBackground,
            color: const Color(0xFFEC4899),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _openFeeTrackerModal(BuildContext context) {
    FeatureModal.show(
      context,
      title: 'Campus Fee Tracker',
      icon: Icons.receipt_long_rounded,
      accentColor: const Color(0xFF0284C7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Semester & Exam Due Dates:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _buildFeeItem('🎓 Semester 6 Tuition Fee', 'Due: 25 Sep 2026', '₹38,000', isPending: true),
          _buildFeeItem('🏢 Hostel & Mess Charges', 'Due: 30 Sep 2026', '₹14,500', isPending: true),
          _buildFeeItem('📝 End Sem Examination Fee', 'Paid on 10 Aug', '₹1,500', isPending: false),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String due, String amount, {required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
              Text(due, style: GoogleFonts.poppins(fontSize: 10.5, color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669))),
            ],
          ),
          Text(amount, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7))),
        ],
      ),
    );
  }
}
