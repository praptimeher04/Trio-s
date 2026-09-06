import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_modal.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'scholarship_screen.dart';
import 'product_details_screen.dart';
import 'chat_screen.dart';
import 'cart_screen.dart';
import 'reseller_dashboard_screen.dart';
import '../widgets/logout_dialog.dart';

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
  int _selectedMarketplaceCategory = 0; // 0: Engineering, 1: Commerce, 2: Science, 3: Booked
  int _selectedTrackerMonthIndex = 8; // Default to September 2026

  final List<Map<String, dynamic>> _monthlySavingsData = [
    {'month': 'Jan', 'savings': 1200.0, 'kharch': 1500.0},
    {'month': 'Feb', 'savings': 1850.0, 'kharch': 1200.0},
    {'month': 'Mar', 'savings': 2400.0, 'kharch': 950.0},
    {'month': 'Apr', 'savings': 1900.0, 'kharch': 1100.0},
    {'month': 'May', 'savings': 3100.0, 'kharch': 800.0},
    {'month': 'Jun', 'savings': 2800.0, 'kharch': 900.0},
    {'month': 'Jul', 'savings': 3500.0, 'kharch': 650.0},
    {'month': 'Aug', 'savings': 2200.0, 'kharch': 700.0},
    {'month': 'Sep', 'savings': 3900.0, 'kharch': 400.0},
  ];

  final TextEditingController _searchController = TextEditingController();
  String _marketplaceSearchQuery = '';

  final Set<String> _likedProductTitles = {};
  final Map<String, double> _productRatings = {};
  final Map<String, String> _productReviews = {};

  List<Map<String, String>> get _favoriteProductsList {
    final all = [..._engineeringProducts, ..._commerceProducts, ..._scienceProducts, ..._bookedProducts];
    final Map<String, Map<String, String>> unique = {};
    for (final p in all) {
      final t = p['title'];
      if (t != null && _likedProductTitles.contains(t)) {
        unique[t] = p;
      }
    }
    return unique.values.toList();
  }

  double _liveWalletBalance = 14500.0;
  double _liveTotalSavings = 12450.0;
  double _liveTotalEarnings = 7800.0;
  double _liveTotalKharch = 8200.0;
  int _liveSavingsCount = 14;

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceProducts();
    _fetchLiveAnalytics();
  }

  Future<void> _fetchLiveAnalytics() async {
    final data = await ApiService.getLiveAnalytics(widget.userEmail);
    if (mounted) {
      setState(() {
        if (data['walletBalance'] != null) {
          _liveWalletBalance = (data['walletBalance'] as num).toDouble();
        }
        if (data['totalSavings'] != null) {
          _liveTotalSavings = (data['totalSavings'] as num).toDouble();
        }
        if (data['totalEarnings'] != null) {
          _liveTotalEarnings = (data['totalEarnings'] as num).toDouble();
        }
        if (data['totalKharch'] != null) {
          _liveTotalKharch = (data['totalKharch'] as num).toDouble();
        }
        if (data['totalSavingsCount'] != null) {
          _liveSavingsCount = (data['totalSavingsCount'] as num).toInt();
        }
        if (data['monthlySavings'] != null && data['monthlySavings'] is List) {
          _monthlySavingsData.clear();
          for (final item in data['monthlySavings']) {
            _monthlySavingsData.add({
              'month': item['month'].toString(),
              'savings': (item['savings'] as num).toDouble(),
              'kharch': (item['kharch'] as num).toDouble(),
            });
          }
        }
      });
    }
  }

  Future<void> _fetchMarketplaceProducts() async {
    final fetched = await ApiService.getAllProducts();
    if (mounted) {
      setState(() {
        _engineeringProducts.clear();
        _commerceProducts.clear();
        _scienceProducts.clear();

        for (final item in fetched) {
          final cat = (item['tag'] ?? '').toLowerCase();
          if (cat.contains('commerce') || cat.contains('finance') || cat.contains('bba') || cat.contains('b.com')) {
            final exists = _commerceProducts.any((existing) => existing['title'] == item['title']);
            if (!exists) _commerceProducts.add(item);
          } else if (cat.contains('science') || cat.contains('bio') || cat.contains('chem') || cat.contains('physics')) {
            final exists = _scienceProducts.any((existing) => existing['title'] == item['title']);
            if (!exists) _scienceProducts.add(item);
          } else {
            final exists = _engineeringProducts.any((existing) => existing['title'] == item['title']);
            if (!exists) _engineeringProducts.add(item);
          }
        }
      });
    }
  }

  final List<Map<String, String>> _cartItems = [
    {
      'title': '📚 Data Structures & Algorithms (Cormen)',
      'price': '₹350',
      'seller': 'Sneha • CSE Dept',
      'tag': 'Textbook',
    },
    {
      'title': '⚡ Scientific Calculator Casio FX-991EX',
      'price': '₹600',
      'seller': 'Ankit • ECE Dept',
      'tag': 'Electronics',
    },
  ];

  final List<Map<String, String>> _bookedProducts = [
    {
      'title': '📚 Data Structures & Algorithms (Cormen)',
      'price': '₹350',
      'seller': 'Sneha • CSE Dept',
      'tag': 'Textbook',
      'condition': 'Reserved • Library Handover',
    },
    {
      'title': '⚡ Scientific Calculator Casio FX-991EX',
      'price': '₹600',
      'seller': 'Ankit • ECE Dept',
      'tag': 'Electronics',
      'condition': 'Paid via Razorpay',
    },
    {
      'title': '🚲 Hero Campus Bicycle (1-Year Used)',
      'price': '₹1,800',
      'seller': 'Vikrant • Mech Dept',
      'tag': 'Vehicle',
      'condition': 'Pickup Scheduled',
    },
  ];

  final List<Map<String, String>> _engineeringProducts = [];
  final List<Map<String, String>> _commerceProducts = [];
  final List<Map<String, String>> _scienceProducts = [];

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

  Future<void> _handleResellerSwap() async {
    final session = await SessionService.getSession();
    final int? userId = session['userId'] != null ? int.tryParse(session['userId'].toString()) : null;

    // Save session as Reseller (userType = 1) when swapping to Reseller Panel
    await SessionService.saveSession(
      isLoggedIn: true,
      userId: userId,
      userType: 1,
      userName: _displayName,
      userEmail: widget.userEmail,
      userRole: 'Reseller',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Switched to Reseller Panel (Type 1) - Welcome $_displayName!'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResellerDashboardScreen(
          resellerName: _displayName,
          resellerEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // 4 Primary Navigation Tabs: Home, Marketplace, Scholarships, Profile
    final List<Widget> pages = [
      _buildHomeDashboardView(),
      _buildMarketplaceView(),
      ScholarshipScreen(userName: _displayName),
=======
    // 4 Clean Tabs: Home, Marketplace, Tracker, Profile
    final List<Widget> pages = [
      _buildHomeDashboardView(),
      _buildMarketplaceView(),
      _buildTrackerView(),
>>>>>>> e6e877d725b8e9e8bb1d827b7bf52010bddab013
      ProfileScreen(
        userName: _displayName,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
        favoriteProducts: _favoriteProductsList,
        onRemoveFavorite: (prod) {
          final t = prod['title'];
          if (t != null) {
            setState(() {
              _likedProductTitles.remove(t);
            });
          }
        },
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topBarBg = isDark ? AppColors.darkSurface : Colors.white;
    final bottomBarBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconColor = isDark ? Colors.white : AppColors.textPrimary;
    final scaffoldBg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: topBarBg,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(isDark ? 50 : 15),
        automaticallyImplyLeading: false,
        leading: _currentBottomNavIndex != 0
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: iconColor),
                onPressed: () {
                  setState(() {
                    _currentBottomNavIndex = 0; // Return to Home tab
                  });
                },
              )
            : null,
        title: _currentBottomNavIndex == 1
            ? Text(
                'Campus Marketplace',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              )
            : _currentBottomNavIndex == 2
                ? Text(
<<<<<<< HEAD
                    'Scholarship Hub',
=======
                    'Savings & Expense Tracker',
>>>>>>> e6e877d725b8e9e8bb1d827b7bf52010bddab013
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  )
<<<<<<< HEAD
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentBottomNavIndex = 3; // Switch to Profile tab
                      });
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
=======
                : _currentBottomNavIndex == 3
                    ? Text(
                        'My Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentBottomNavIndex = 3; // Switch to Profile tab
                          });
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
>>>>>>> e6e877d725b8e9e8bb1d827b7bf52010bddab013
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${widget.userRole} • #2026-CS-892',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      color: textSecondary,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
        actions: [
          // 1. Swap Icon Button (ALWAYS VISIBLE IN TOP BAR)
          IconButton(
            tooltip: 'Swap to Reseller Panel (Type 1)',
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFA7F3D0), width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF059669), size: 20),
            ),
            onPressed: _handleResellerSwap,
          ),

          if (_currentBottomNavIndex == 1) ...[
            // MARKETPLACE TAB: CART BUTTON
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  tooltip: 'Shopping Cart',
                  icon: Icon(Icons.shopping_cart_outlined, color: iconColor, size: 24),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CartScreen(
                          cartItems: _cartItems,
                          userName: widget.userName,
                          userEmail: widget.userEmail,
                          onCartCleared: () {
                            setState(() {
                              _cartItems.clear();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_cartItems.length}',
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
            const SizedBox(width: 4),
          ] else ...[
            // OTHER TABS: NOTIFICATION BELL
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: iconColor, size: 24),
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
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '$_unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          // LOGOUT BUTTON
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout_rounded, color: textSecondary, size: 22),
            onPressed: () => showLogoutConfirmationDialog(context),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // SCREEN BODY (Selected Tab View)
      body: pages[_currentBottomNavIndex],

      // MAIN BOTTOM NAVIGATION BAR (4 Clean Tabs)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bottomBarBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 15),
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
            if (index == 1) {
              _fetchMarketplaceProducts();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomBarBg,
          selectedItemColor: isDark ? AppColors.secondary : AppColors.primary,
          unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w500),
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
<<<<<<< HEAD
              icon: Icon(Icons.workspace_premium_rounded),
              label: 'Scholarships',
=======
              icon: Icon(Icons.analytics_rounded),
              label: 'Tracker',
>>>>>>> e6e877d725b8e9e8bb1d827b7bf52010bddab013
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;

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
              color: titleColor,
            ),
          ),
          const SizedBox(height: 14),
          _buildMiddleMetricsGrid(),
          const SizedBox(height: 28),

          // MAIN FEATURES GRID (Marketplace, Reseller Panel, Wallet, Savings, Fee Tracker)
          Text(
            'Main Campus Services',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);
    final inputTextColor = isDark ? Colors.white : Colors.black87;

    final categories = [
      {'name': 'Engineering', 'icon': Icons.engineering_rounded},
      {'name': 'Commerce', 'icon': Icons.storefront_rounded},
      {'name': 'Science', 'icon': Icons.science_rounded},
      {'name': 'Booked Items', 'icon': Icons.bookmark_added_rounded},
    ];

    List<Map<String, String>> currentProducts;
    if (_selectedMarketplaceCategory == 1) {
      currentProducts = _commerceProducts;
    } else if (_selectedMarketplaceCategory == 2) {
      currentProducts = _scienceProducts;
    } else if (_selectedMarketplaceCategory == 3) {
      currentProducts = _bookedProducts;
    } else {
      currentProducts = _engineeringProducts;
    }

    if (_marketplaceSearchQuery.isNotEmpty) {
      currentProducts = currentProducts.where((prod) {
        final title = (prod['title'] ?? '').toLowerCase();
        final seller = (prod['seller'] ?? '').toLowerCase();
        final tag = (prod['tag'] ?? '').toLowerCase();
        return title.contains(_marketplaceSearchQuery) ||
            seller.contains(_marketplaceSearchQuery) ||
            tag.contains(_marketplaceSearchQuery);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buy and sell books, equipment, and gear with verified campus peers.',
            style: GoogleFonts.poppins(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 14),

          // SEARCH BAR ABOVE SUB-TABS
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 12.5, color: inputTextColor),
              onChanged: (val) {
                setState(() {
                  _marketplaceSearchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search product by name, seller or department...',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: textSecondary),
                prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                suffixIcon: _marketplaceSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _marketplaceSearchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SUB-TABS: Engineering, Commerce, Science, Booked Items
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categories.length, (index) {
                final isSelected = _selectedMarketplaceCategory == index;
                final cat = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMarketplaceCategory = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0B6E4F) : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0B6E4F) : borderColor,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0B6E4F).withAlpha(50),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 16,
                            color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF374151)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // CATEGORY PRODUCT LISTING HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categories[_selectedMarketplaceCategory]['name']} Items (${currentProducts.length})',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? Border.all(color: AppColors.darkSurfaceBorder) : null,
                ),
                child: Text(
                  'Verified Peers',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (currentProducts.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 40,
                      color: Color(0xFF0B6E4F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products available in this category yet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Products published by resellers or peers will appear here.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...currentProducts.map((prod) {
              return _buildMarketplaceTile(prod);
            }),
          ],
        ],
      ),
    );
  }

  void _showRatingDialog(Map<String, String> prod) {
    final title = prod['title'] ?? 'Product';
    double selectedRating = _productRatings[title] ?? 5.0;
    final reviewController = TextEditingController(text: _productReviews[title] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rate & Review Product',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Rating:',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = (index + 1).toDouble();
                        return IconButton(
                          icon: Icon(
                            starVal <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = starVal;
                            });
                          },
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        '${selectedRating.toInt()} / 5 Stars',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Write a Review:',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your experience with this product...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6E4F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _productRatings[title] = selectedRating;
                      _productReviews[title] = reviewController.text.trim();
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you! Rating saved for $title'),
                        backgroundColor: const Color(0xFF0B6E4F),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Submit Review', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMarketplaceTile(Map<String, String> prod) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);

    final title = prod['title'] ?? '';
    final price = prod['price'] ?? '';
    final seller = prod['seller'] ?? '';
    final tag = prod['tag'];
    final condition = prod['condition'];
    final imageUrl = prod['image'];
    final isLiked = _likedProductTitles.contains(title);
    final rating = _productRatings[title];
    final review = _productReviews[title];
    final isBookedCategory = _selectedMarketplaceCategory == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: prod,
                userName: _displayName,
                userEmail: widget.userEmail,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THUMBNAIL IMAGE (64x64)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFECFDF5),
                                child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0B6E4F), size: 28),
                              ),
                            )
                          : Container(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFECFDF5),
                              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0B6E4F), size: 28),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // TITLE, SELLER, TAGS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          seller,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (tag != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                            if (condition != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  condition,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9333EA),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // PRICE & ACTIONS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0B6E4F),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            tooltip: isLiked ? 'Remove from favorites' : 'Add to favorites',
                            icon: Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: isLiked ? Colors.red : const Color(0xFF9CA3AF),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isLiked) {
                                  _likedProductTitles.remove(title);
                                } else {
                                  _likedProductTitles.add(title);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            tooltip: 'Chat with Reseller',
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF0B6E4F)),
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final String resellerEmail = (prod['sellerEmail'] != null && prod['sellerEmail']!.isNotEmpty)
                                  ? prod['sellerEmail']!
                                  : 'sneha.cse@campus.edu';

                              final convData = await ApiService.getOrCreateConversation(
                                customerEmail: widget.userEmail,
                                customerName: _displayName,
                                resellerEmail: resellerEmail,
                                resellerName: seller,
                                productTitle: title,
                              );

                              final int? convId = convData != null && convData['conversationId'] != null
                                  ? int.tryParse(convData['conversationId'].toString())
                                  : null;

                              if (!mounted) return;
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    conversationId: convId,
                                    sellerName: seller,
                                    productTitle: title,
                                    productPrice: price,
                                    productImage: imageUrl,
                                    sellerAvatar: prod['avatar'] ?? (seller.isNotEmpty ? seller[0].toUpperCase() : 'S'),
                                    currentUserName: _displayName,
                                    currentUserEmail: widget.userEmail,
                                    peerEmail: resellerEmail,
                                    isReseller: false,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          if (isBookedCategory)
                            ElevatedButton.icon(
                              onPressed: () => _showRatingDialog(prod),
                              icon: const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                              label: Text(
                                rating != null ? 'Edit Rate' : 'Rate',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B6E4F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      product: prod,
                                      userName: _displayName,
                                      userEmail: widget.userEmail,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B6E4F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              child: Text(
                                'View',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (rating != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} / 5.0',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFB45309)),
                      ),
                      if (review != null && review.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"$review"',
                            style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF78350F)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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
            '₹${_liveWalletBalance.toStringAsFixed(2)}',
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
      childAspectRatio: 1.35,
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentBottomNavIndex = 2),
          child: _buildMetricCard('Total Savings', '₹${_liveTotalSavings.toStringAsFixed(2)}', 'Live DB Calculation', Icons.savings_rounded, const Color(0xFF10B981)),
        ),
        GestureDetector(
          onTap: () => setState(() => _currentBottomNavIndex = 2),
          child: _buildMetricCard('Marketplace Earned', '₹${_liveTotalEarnings.toStringAsFixed(2)}', 'Live Reseller Sales', Icons.trending_up_rounded, const Color(0xFF059669)),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.surfaceBorder;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
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
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: iconColor.withAlpha(25), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // --- MAIN FEATURE GRID (Scholarships, Marketplace, Wallet, Savings, Fee Tracker) ---
=======
  // --- MAIN FEATURE GRID (Marketplace, Reseller Panel, Wallet, Tracker, Savings, Fee Tracker) ---
>>>>>>> e6e877d725b8e9e8bb1d827b7bf52010bddab013
  Widget _buildMainFeatureGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.surfaceBorder;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final List<Map<String, dynamic>> features = [
      {
        'title': 'Scholarships',
        'subtitle': 'Grants & Disbursal Tracker',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF0D5C3A),
        'onTap': () => setState(() => _currentBottomNavIndex = 2),
      },
      {
        'title': 'Marketplace',
        'subtitle': 'Buy & Sell Textbooks',
        'icon': Icons.storefront_rounded,
        'color': const Color(0xFF059669),
        'onTap': () => setState(() => _currentBottomNavIndex = 1),
      },
      {
        'title': 'Savings Tracker',
        'subtitle': 'Graphs & Kharch Analysis',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => setState(() => _currentBottomNavIndex = 2),
      },
      {
        'title': 'Reseller Panel',
        'subtitle': 'Swap to Seller Mode (Type 1)',
        'icon': Icons.swap_horiz_rounded,
        'color': const Color(0xFF0D9488),
        'onTap': _handleResellerSwap,
      },
      {
        'title': 'Wallet',
        'subtitle': 'Manage Accounts & Cards',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF0284C7),
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
        'color': const Color(0xFF8B5CF6),
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
        childAspectRatio: 1.3,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feat = features[index];
        final Color color = feat['color'] as Color;
        return InkWell(
          onTap: feat['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 8),
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
                Text(feat['title'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                Text(feat['subtitle'] as String, style: GoogleFonts.poppins(fontSize: 10.5, color: textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  // --- TAB 3: SAVINGS & EXPENSE TRACKER VIEW ---
  Widget _buildTrackerView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    final selectedMonthData = _monthlySavingsData[_selectedTrackerMonthIndex];
    final double maxSavings = _monthlySavingsData.map((e) => e['savings'] as double).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER HERO BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withAlpha(60),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Student Savings Tracker',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                        '2026 ANALYTICS',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '₹${_liveTotalSavings.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Total Cumulative Student Money Saved',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marketplace Saved & Earned', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text('₹${_liveTotalEarnings.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Kharch (Spent)', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text('₹${_liveTotalKharch.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFECACA))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2x2 METRICS GRID
          Text(
            'Financial Breakdown Cards',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildTrackerCard(
                title: 'Student Savings',
                amount: '₹${_liveTotalSavings.toStringAsFixed(2)}',
                subtitle: 'Discounts & Waivers',
                icon: Icons.school_rounded,
                color: const Color(0xFF059669),
                bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
              ),
              _buildTrackerCard(
                title: 'Marketplace Saved/Earned',
                amount: '₹${_liveTotalEarnings.toStringAsFixed(2)}',
                subtitle: 'Used Books & Resale',
                icon: Icons.storefront_rounded,
                color: const Color(0xFF0D9488),
                bgColor: isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1),
              ),
              _buildTrackerCard(
                title: 'Total Saving Count',
                amount: '$_liveSavingsCount Saved Items',
                subtitle: 'Cumulative Items',
                icon: Icons.tag_rounded,
                color: const Color(0xFF2563EB),
                bgColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
              ),
              _buildTrackerCard(
                title: 'Total Kharch',
                amount: '₹${_liveTotalKharch.toStringAsFixed(2)}',
                subtitle: 'Campus Expenditure',
                icon: Icons.payments_rounded,
                color: const Color(0xFFDC2626),
                bgColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MONTHLY SAVINGS GRAPH
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 30 : 8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Savings Graph',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Month-by-month savings growth (2026)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: Color(0xFF059669), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+34% YoY',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SELECTED MONTH HIGHLIGHT POPUP CARD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF059669), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Month: ${selectedMonthData['month']} 2026',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Savings: ', style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
                          Text('₹${(selectedMonthData['savings'] as double).toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
                          const SizedBox(width: 10),
                          Text('Kharch: ', style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
                          Text('₹${(selectedMonthData['kharch'] as double).toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BAR CHART IMPLEMENTATION
                SizedBox(
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_monthlySavingsData.length, (index) {
                      final item = _monthlySavingsData[index];
                      final savingsVal = item['savings'] as double;
                      final isSelected = index == _selectedTrackerMonthIndex;
                      final double barHeightRatio = (savingsVal / maxSavings).clamp(0.15, 1.0);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTrackerMonthIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(savingsVal / 1000).toStringAsFixed(1)}k',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF059669) : textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 22,
                              height: 110 * barHeightRatio,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF059669) : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                                borderRadius: BorderRadius.circular(6),
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF047857)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF059669).withAlpha(80),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['month'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF059669) : textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // DETAILED TRANSACTIONS & KHARCH BREAKDOWN LIST
          Text(
            'Recent Savings & Kharch Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTrackerTransactionTile(
            title: 'Data Structures Book (Cormen)',
            category: 'Marketplace • Textbook',
            date: 'Sep 4, 2026',
            kharch: '₹350',
            saved: '₹450',
            icon: Icons.book_rounded,
            iconColor: const Color(0xFF2563EB),
          ),
          _buildTrackerTransactionTile(
            title: 'Casio Scientific Calculator',
            category: 'Marketplace • Electronics',
            date: 'Sep 2, 2026',
            kharch: '₹600',
            saved: '₹900',
            icon: Icons.calculate_rounded,
            iconColor: const Color(0xFF0D9488),
          ),
          _buildTrackerTransactionTile(
            title: 'Tuition Fee Early Bird Subsidy',
            category: 'Student Savings • Fee Discount',
            date: 'Aug 28, 2026',
            kharch: '₹5,000',
            saved: '₹2,500',
            icon: Icons.card_membership_rounded,
            iconColor: const Color(0xFF059669),
          ),
          _buildTrackerTransactionTile(
            title: 'Sold Engineering Drawing Kit',
            category: 'Marketplace • Reseller Profit',
            date: 'Aug 15, 2026',
            kharch: '+₹1,200',
            saved: '₹1,200',
            icon: Icons.sell_rounded,
            iconColor: const Color(0xFFEC4899),
            isProfit: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrackerCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TRACKED',
                  style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerTransactionTile({
    required String title,
    required String category,
    required String date,
    required String kharch,
    required String saved,
    required IconData icon,
    required Color iconColor,
    bool isProfit = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$category • $date',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isProfit ? 'Earned: $kharch' : 'Kharch: $kharch',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Saved: $saved',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}
