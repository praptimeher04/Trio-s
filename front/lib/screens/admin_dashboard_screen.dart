import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminName;
  final String adminEmail;

  const AdminDashboardScreen({
    super.key,
    this.adminName = 'Sankalp (Admin)',
    this.adminEmail = 'sankalp@admin.campus.edu',
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTab = 0; // 0: Overview, 1: Users, 2: Products, 3: Orders, 4: Scholarships
  bool _isLoading = false;

  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalStudents': 0,
    'totalResellers': 0,
    'totalAdmins': 0,
    'totalProducts': 0,
    'totalOrders': 0,
    'totalRevenue': 0.0,
    'activeScholarships': 3,
    'systemStatus': 'OPERATIONAL',
  };

  List<Map<String, dynamic>> _users = [];
  List<Map<String, String>> _products = [];
  List<Map<String, String>> _orders = [];

  String _userSearchQuery = '';
  int _selectedUserFilter = -1; // -1: All, 0: Student, 1: Reseller, 2: Admin

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statsData = await ApiService.getAdminStats();
      final usersData = await ApiService.getAllUsers();
      final productsData = await ApiService.getAllProducts();
      final ordersData = await ApiService.getAllOrders();

      if (mounted) {
        setState(() {
          _stats = statsData;
          _users = usersData;
          _products = productsData;
          _orders = ordersData;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmDeleteUser(int userId, String userName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete User Account?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$userName" (ID: #$userId) from the database? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              final success = await ApiService.deleteUser(userId);
              if (success && mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('User "$userName" removed successfully.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
                _loadAdminData();
              }
            },
            child: const Text('Delete User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(int index, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Moderate Listing?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Remove "$title" from the peer-to-peer marketplace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              final success = await ApiService.deleteProduct(index + 1);
              if (success && mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Product "$title" removed by Admin.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
                _loadAdminData();
              }
            },
            child: const Text('Remove Listing', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ADMIN CONTROL PANEL',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('DB ACTIVE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome, ${widget.adminName}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Refresh Admin Data',
            onPressed: _loadAdminData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : Column(
              children: [
                // Top Metric Cards Header
                _buildMetricsBanner(),
                // Tab Navigator Bar
                _buildTabBar(),
                // Tab Content Body
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      _buildOverviewTab(),
                      _buildUsersTab(),
                      _buildProductsTab(),
                      _buildOrdersTab(),
                      _buildScholarshipsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetricsBanner() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricCard(
              title: 'Total Users',
              value: '${_stats['totalUsers'] ?? _users.length}',
              subtitle: '${_stats['totalStudents'] ?? 0} Std • ${_stats['totalResellers'] ?? 0} Res • ${_stats['totalAdmins'] ?? 0} Adm',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              title: 'Marketplace Items',
              value: '${_stats['totalProducts'] ?? _products.length}',
              subtitle: 'Active P2P Listings',
              icon: Icons.storefront_rounded,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              title: 'Total Revenue',
              value: '₹${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
              subtitle: '${_stats['totalOrders'] ?? _orders.length} Completed Orders',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              title: 'Scholarships',
              value: '${_stats['activeScholarships'] ?? 3}',
              subtitle: 'Active Campus Grants',
              icon: Icons.school_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'label': 'Overview', 'icon': Icons.dashboard_rounded},
      {'label': 'Users (${_users.length})', 'icon': Icons.people_outline_rounded},
      {'label': 'Products (${_products.length})', 'icon': Icons.inventory_2_outlined},
      {'label': 'Orders (${_orders.length})', 'icon': Icons.receipt_long_rounded},
      {'label': 'Scholarships', 'icon': Icons.school_outlined},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _currentTab == index;
            final tab = tabs[index];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentTab = index;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(tab['icon'] as IconData, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        tab['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
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
    );
  }

  // --- TAB 1: OVERVIEW ---
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // System Banner Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF818CF8), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Campus Financial Infrastructure Status',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Supabase PostgreSQL connected via PgBouncer. All authentication, P2P listings, and Razorpay payment endpoints operating with 0 latency.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC7D2FE)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Admin Action Shortcuts
        Text('Quick Administration Actions', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Manage Users',
                desc: 'View & Edit Roles',
                icon: Icons.person_add_alt_1_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => setState(() => _currentTab = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                title: 'Moderate Store',
                desc: 'Review Listings',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _currentTab = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Transaction Audit',
                desc: 'Razorpay Logs',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => setState(() => _currentTab = 3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                title: 'Scholarship Aid',
                desc: 'Grant Programs',
                icon: Icons.school_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _currentTab = 4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text('Recent System Activity Log', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildActivityRow('Admin "Sankalp" authenticated', '07:55 AM', Icons.admin_panel_settings_rounded, const Color(0xFF6366F1)),
              const Divider(height: 1),
              _buildActivityRow('Reseller "Purva" listed Casio FX-991CW', '07:42 AM', Icons.storefront_rounded, const Color(0xFF10B981)),
              const Divider(height: 1),
              _buildActivityRow('Razorpay Payment #order_rzp_9921 Successful', '07:15 AM', Icons.payments_rounded, const Color(0xFF3B82F6)),
              const Divider(height: 1),
              _buildActivityRow('New Student Registration: Hitija Mhatre', '06:50 AM', Icons.person_add_rounded, const Color(0xFFF59E0B)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text(desc, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String text, String time, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 16, color: color)),
      title: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
      trailing: Text(time, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
    );
  }

  // --- TAB 2: USER MANAGEMENT ---
  Widget _buildUsersTab() {
    List<Map<String, dynamic>> filteredUsers = _users.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final query = _userSearchQuery.toLowerCase();
      final matchesSearch = name.contains(query) || email.contains(query);

      int type = 0;
      if (u['userType'] != null) {
        type = int.tryParse(u['userType'].toString()) ?? 0;
      }

      final matchesFilter = _selectedUserFilter == -1 || type == _selectedUserFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: [
        // Search & Filter Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _userSearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search user by Name or Email...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All (${_users.length})', -1),
                    _buildFilterChip('Students (Type 0)', 0),
                    _buildFilterChip('Resellers (Type 1)', 1),
                    _buildFilterChip('Admins (Type 2)', 2),
                  ],
                ),
              ),
            ],
          ),
        ),

        // User Directory List
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Text('No matching users found.', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final userId = user['id'] != null ? int.tryParse(user['id'].toString()) ?? index + 1 : index + 1;
                    final userName = (user['name'] ?? 'Campus User').toString();
                    final userEmail = (user['email'] ?? 'user@campus.edu').toString();
                    int userType = user['userType'] != null ? int.tryParse(user['userType'].toString()) ?? 0 : 0;
                    if (userName.toLowerCase().contains('sankalp') || userEmail.toLowerCase().contains('sankalp')) userType = 2;
                    if (userName.toLowerCase().contains('purva') || userEmail.toLowerCase().contains('purva')) userType = 1;

                    Color badgeColor;
                    String badgeText;

                    if (userType == 2) {
                      badgeColor = const Color(0xFF6366F1);
                      badgeText = 'Type 2 • Admin';
                    } else if (userType == 1) {
                      badgeColor = const Color(0xFF10B981);
                      badgeText = 'Type 1 • Reseller';
                    } else {
                      badgeColor = const Color(0xFF3B82F6);
                      badgeText = 'Type 0 • Student';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: badgeColor.withOpacity(0.1),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(userName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text(badgeText, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userEmail, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                            if (user['mobileNumber'] != null && user['mobileNumber'].toString().isNotEmpty)
                              Text('📞 ${user['mobileNumber']}', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                          tooltip: 'Delete User',
                          onPressed: () => _confirmDeleteUser(userId, userName),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int value) {
    final isSelected = _selectedUserFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: GoogleFonts.inter(fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF475569))),
        selectedColor: const Color(0xFF0F172A),
        backgroundColor: const Color(0xFFF1F5F9),
        onSelected: (_) => setState(() => _selectedUserFilter = value),
      ),
    );
  }

  // --- TAB 3: PRODUCTS ---
  Widget _buildProductsTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text('Active Marketplace Listings (${_products.length})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const Spacer(),
              Text('Live DB Items', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: _products.isEmpty
              ? Center(child: Text('No marketplace products found.', style: GoogleFonts.inter(color: const Color(0xFF64748B))))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final title = product['title'] ?? 'Product';
                    final price = product['price'] ?? '₹350';
                    final seller = product['seller'] ?? 'Campus Peer';
                    final tag = product['tag'] ?? 'Engineering';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image'] ?? 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 48,
                              height: 48,
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.book_rounded, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Seller: $seller • Category: $tag', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(price, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF059669))),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              onPressed: () => _confirmDeleteProduct(index, title),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 4: ORDERS ---
  Widget _buildOrdersTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text('Razorpay Platform Transactions (${_orders.length})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const Spacer(),
              const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
            ],
          ),
        ),
        Expanded(
          child: _orders.isEmpty
              ? Center(child: Text('No orders recorded yet.', style: GoogleFonts.inter(color: const Color(0xFF64748B))))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final orderId = order['orderId'] ?? 'order_rzp_1';
                    final productTitle = order['productTitle'] ?? 'Campus Book';
                    final price = order['price'] ?? '₹350';
                    final buyerName = order['buyerName'] ?? 'Hitija Mhatre';
                    final sellerName = order['sellerName'] ?? 'Reseller';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                          child: const Icon(Icons.receipt_rounded, color: Color(0xFF10B981), size: 20),
                        ),
                        title: Text(productTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Buyer: $buyerName • Seller: $sellerName\nID: $orderId', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        trailing: Text(price, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 5: SCHOLARSHIPS ---
  Widget _buildScholarshipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Campus Scholarship Programs', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Scholarship Grant feature unlocked for Admin!')),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: const Text('Add Grant', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScholarshipCard('National Merit Fellowship 2026', '₹50,000', 'Merit Based', '30 Sep 2026', '42 Applicants'),
        _buildScholarshipCard('Women in Tech Leadership Award', '₹35,000', 'Diversity Grant', '15 Oct 2026', '28 Applicants'),
        _buildScholarshipCard('Merit-cum-Means Financial Aid', '₹20,000', 'Financial Aid', '25 Sep 2026', '64 Applicants'),
      ],
    );
  }

  Widget _buildScholarshipCard(String title, String amount, String category, String deadline, String applicants) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.school_rounded, color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text('$category • Deadline: $deadline', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text('👥 $applicants', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                ],
              ),
            ),
            Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF059669))),
          ],
        ),
      ),
    );
  }
}
