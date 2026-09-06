import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  final String adminName;
  final String adminEmail;

  const SuperAdminDashboardScreen({
    super.key,
    this.adminName = 'Sankalp (Super Admin)',
    this.adminEmail = 'sankalp@admin.campus.edu',
  });

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  // Light Green FinTech Design System Tokens
  static const Color primaryLightGreen = Color(0xFF059669);
  static const Color secondaryEmerald = Color(0xFF10B981);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color mintAccent = Color(0xFFD1FAE5);
  static const Color mintBg = Color(0xFFECFDF5);
  static const Color bgSurface = Color(0xFFF2FBF6);
  static const Color borderMint = Color(0xFFA7F3D0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF475569);

  // Navigation State
  String _activeCategory = 'Dashboard';
  String _activeSubView = 'Overview';

  // Interactive Chart & Flow State
  int _selectedMonthIndex = 5;
  int _selectedStageIndex = 3;

  bool _isLoading = false;

  // Data Stores
  Map<String, dynamic> _stats = {
    'totalUsers': 1248,
    'totalStudents': 1234,
    'totalResellers': 12,
    'totalAdmins': 14,
    'totalProducts': 156,
    'totalOrders': 3890,
    'totalRevenue': 485000.0,
    'totalApplications': 286,
    'activeScholarships': 28,
    'systemStatus': 'OPERATIONAL',
  };

  // Mock Students Data with complete details
  final List<Map<String, dynamic>> _studentsList = [
    {
      'id': 101,
      'name': 'Hitija Mhatre',
      'email': 'hitija@student.campus.edu',
      'phone': '+91 98765 43210',
      'rollNo': 'STU-2026-889',
      'department': 'Computer Engineering',
      'batch': '2022-2026',
      'regDate': '2026-08-15',
      'status': 'Active',
      'scholarships': [
        {'title': 'State Merit Scholarship', 'amount': 35000, 'status': 'Approved'},
        {'title': 'Tech Innovator Grant', 'amount': 10000, 'status': 'Approved'},
      ],
      'fees': {
        'totalFee': 65000,
        'paidFee': 65000,
        'pendingDues': 0,
        'lastPaymentTxn': 'RAZORPAY_TXN_99812',
      },
      'marketplace': {
        'itemsBought': 4,
        'itemsListed': 2,
        'itemsSold': 1,
        'totalSpent': 2400,
        'totalEarned': 850,
        'walletBalance': 1250,
      },
      'financialSummary': {
        'score': 94,
        'scoreCategory': 'Excellent',
        'totalAidReceived': 45000,
        'savingsRate': '42%',
        'aidBalance': 12500,
      },
    },
    {
      'id': 102,
      'name': 'Rohan Sharma',
      'email': 'rohan.sharma@student.campus.edu',
      'phone': '+91 91234 56789',
      'rollNo': 'STU-2026-442',
      'department': 'Information Technology',
      'batch': '2023-2027',
      'regDate': '2026-08-20',
      'status': 'Active',
      'scholarships': [
        {'title': 'Campus Need-Based Assistance', 'amount': 20000, 'status': 'Pending'},
      ],
      'fees': {
        'totalFee': 70000,
        'paidFee': 40000,
        'pendingDues': 30000,
        'lastPaymentTxn': 'RAZORPAY_TXN_77412',
      },
      'marketplace': {
        'itemsBought': 2,
        'itemsListed': 0,
        'itemsSold': 0,
        'totalSpent': 950,
        'totalEarned': 0,
        'walletBalance': 500,
      },
      'financialSummary': {
        'score': 78,
        'scoreCategory': 'Good',
        'totalAidReceived': 20000,
        'savingsRate': '28%',
        'aidBalance': 5000,
      },
    },
    {
      'id': 103,
      'name': 'Ananya Patel',
      'email': 'ananya.p@student.campus.edu',
      'phone': '+91 99887 11223',
      'rollNo': 'STU-2026-901',
      'department': 'Electronics & Telecom',
      'batch': '2022-2026',
      'regDate': '2026-08-10',
      'status': 'Blocked',
      'scholarships': [],
      'fees': {
        'totalFee': 65000,
        'paidFee': 20000,
        'pendingDues': 45000,
        'lastPaymentTxn': 'NONE',
      },
      'marketplace': {
        'itemsBought': 0,
        'itemsListed': 3,
        'itemsSold': 0,
        'totalSpent': 0,
        'totalEarned': 0,
        'walletBalance': 0,
      },
      'financialSummary': {
        'score': 45,
        'scoreCategory': 'Requires Review',
        'totalAidReceived': 0,
        'savingsRate': '0%',
        'aidBalance': 0,
      },
    },
  ];

  // Mock Admins List
  final List<Map<String, dynamic>> _adminsList = [
    {
      'id': 1,
      'name': 'Sankalp (Super Admin)',
      'email': 'sankalp@admin.campus.edu',
      'role': 'Super Admin',
      'userType': 2,
      'phone': '+91 99887 76655',
      'createdDate': '2026-08-01',
    },
    {
      'id': 2,
      'name': 'Purva Admin',
      'email': 'purva@reseller.campus.edu',
      'role': 'Merchant Admin',
      'userType': 1,
      'phone': '+91 98765 11122',
      'createdDate': '2026-08-05',
    },
  ];

  // Mock Scholarships List
  final List<Map<String, dynamic>> _scholarshipsList = [
    {
      'id': 'SCH-01',
      'name': 'State Merit Scholarship 2026',
      'amount': '₹35,000',
      'eligibility': 'CGPA > 8.5 • Family Income < ₹6L',
      'deadline': '30 Oct 2026',
      'description': 'Merit aid for academic excellence.',
      'totalApplications': 142,
    },
    {
      'id': 'SCH-02',
      'name': 'Tech Innovator Grant',
      'amount': '₹15,000',
      'eligibility': 'STEM Department Students',
      'deadline': '15 Nov 2026',
      'description': 'Research grant for technical innovation.',
      'totalApplications': 48,
    },
  ];

  // Mock Applications List
  final List<Map<String, dynamic>> _applicationsList = [
    {
      'appId': 'APP-901',
      'studentName': 'Hitija Mhatre',
      'studentEmail': 'hitija@student.campus.edu',
      'scholarshipName': 'State Merit Scholarship 2026',
      'amount': 35000,
      'gpa': '9.4',
      'status': 'Approved',
      'appliedDate': '2026-08-18',
    },
    {
      'appId': 'APP-902',
      'studentName': 'Rohan Sharma',
      'studentEmail': 'rohan.sharma@student.campus.edu',
      'scholarshipName': 'Campus Need-Based Assistance',
      'amount': 20000,
      'gpa': '8.2',
      'status': 'Pending',
      'appliedDate': '2026-08-22',
    },
    {
      'appId': 'APP-903',
      'studentName': 'Priya Nair',
      'studentEmail': 'priya.nair@student.campus.edu',
      'scholarshipName': 'Tech Innovator Grant',
      'amount': 15000,
      'gpa': '8.8',
      'status': 'Under Review',
      'appliedDate': '2026-08-25',
    },
    {
      'appId': 'APP-904',
      'studentName': 'Amit Kumar',
      'studentEmail': 'amit.k@student.campus.edu',
      'scholarshipName': 'State Merit Scholarship 2026',
      'amount': 35000,
      'gpa': '6.9',
      'status': 'Rejected',
      'appliedDate': '2026-08-16',
    },
  ];

  // Mock Marketplace Products
  final List<Map<String, dynamic>> _marketplaceProducts = [
    {
      'id': 201,
      'title': 'Engineering Physics Textbook',
      'sellerName': 'Hitija Mhatre',
      'sellerEmail': 'hitija@student.campus.edu',
      'price': 450,
      'category': 'Books',
      'status': 'Listings',
      'isReported': false,
    },
    {
      'id': 202,
      'title': 'Scientific Calculator FX-991EX',
      'sellerName': 'Rohan Sharma',
      'sellerEmail': 'rohan.sharma@student.campus.edu',
      'price': 850,
      'category': 'Electronics',
      'status': 'Listings',
      'isReported': false,
    },
    {
      'id': 203,
      'title': 'Unapproved Equipment Kit',
      'sellerName': 'Ananya Patel',
      'sellerEmail': 'ananya.p@student.campus.edu',
      'price': 1200,
      'category': 'Equipment',
      'status': 'Reports',
      'isReported': true,
    },
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSuperAdminData();
  }

  Future<void> _loadSuperAdminData() async {
    setState(() => _isLoading = true);
    try {
      final statsData = await ApiService.getAdminStats();
      final usersData = await ApiService.getAllUsers();
      final backendSchs = await ApiService.getAvailableScholarships();
      if (mounted) {
        setState(() {
          _stats = statsData;
          if (usersData.isNotEmpty) {
            _stats['totalUsers'] = usersData.length;
          }
          if (backendSchs.isNotEmpty) {
            _scholarshipsList.clear();
            for (final item in backendSchs) {
              _scholarshipsList.add({
                'id': item['id']?.toString() ?? 'SCH-01',
                'name': item['title'] ?? item['name'] ?? 'Scholarship Grant',
                'amount': item['amount'] ?? '₹25,000',
                'eligibility': item['criteria'] ?? item['eligibility'] ?? 'All Students',
                'deadline': item['deadline'] ?? '30 Oct 2026',
                'description': item['description'] ?? '',
                'totalApplications': 142,
              });
            }
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // --- Student Actions & 5-Tab Profile Modal ---
  void _updateStudentStatus(int studentId, String newStatus) {
    setState(() {
      final index = _studentsList.indexWhere((s) => s['id'] == studentId);
      if (index != -1) {
        _studentsList[index]['status'] = newStatus;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student status set to "$newStatus"'),
        backgroundColor: newStatus == 'Active' ? primaryLightGreen : Colors.red,
      ),
    );
  }

  void _showStudentProfileModal(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DefaultTabController(
          length: 5,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Modal Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: mintAccent,
                            child: Text(
                              student['name'][0],
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: darkForest),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student['name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                              Text(student['email'], style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // 5 Tab Selector Bar
                TabBar(
                  isScrollable: true,
                  labelColor: primaryLightGreen,
                  unselectedLabelColor: textMuted,
                  indicatorColor: primaryLightGreen,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Personal Details'),
                    Tab(text: 'Scholarship Details'),
                    Tab(text: 'Fee Details'),
                    Tab(text: 'Marketplace Activity'),
                    Tab(text: 'Financial Summary'),
                  ],
                ),

                const Divider(height: 1, color: borderMint),

                // Tab Views Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Personal Details
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            _buildInfoGrid([
                              _buildInfoTile('Roll Number', student['rollNo'] ?? 'N/A'),
                              _buildInfoTile('Department', student['department'] ?? 'N/A'),
                              _buildInfoTile('Mobile Number', student['phone'] ?? 'N/A'),
                              _buildInfoTile('Batch Year', student['batch'] ?? 'N/A'),
                              _buildInfoTile('Registration Date', student['regDate'] ?? 'N/A'),
                              _buildStatusTile('Account Status', student['status']),
                            ]),
                          ],
                        ),
                      ),

                      // Tab 2: Scholarship Details
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            if ((student['scholarships'] as List).isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: bgSurface, borderRadius: BorderRadius.circular(12)),
                                child: Text('No active scholarships granted.', style: GoogleFonts.inter(color: textMuted)),
                              )
                            else
                              Column(
                                children: (student['scholarships'] as List).map((sch) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderMint)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(sch['title'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
                                            Text('Grant Amount: ₹${sch['amount']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: primaryLightGreen, borderRadius: BorderRadius.circular(20)),
                                          child: Text(sch['status'], style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      // Tab 3: Fee Details
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            _buildInfoGrid([
                              _buildInfoTile('Total Semester Fee', '₹${student['fees']['totalFee']}'),
                              _buildInfoTile('Fees Paid', '₹${student['fees']['paidFee']}'),
                              _buildInfoTile('Pending Dues', '₹${student['fees']['pendingDues']}'),
                              _buildInfoTile('Last Txn Reference', student['fees']['lastPaymentTxn']),
                            ]),
                          ],
                        ),
                      ),

                      // Tab 4: Marketplace Activity
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            _buildInfoGrid([
                              _buildInfoTile('Items Purchased', '${student['marketplace']['itemsBought']} items'),
                              _buildInfoTile('Items Listed', '${student['marketplace']['itemsListed']} items'),
                              _buildInfoTile('Items Sold', '${student['marketplace']['itemsSold']} items'),
                              _buildInfoTile('Total Spent', '₹${student['marketplace']['totalSpent']}'),
                              _buildInfoTile('Total Earned', '₹${student['marketplace']['totalEarned']}'),
                              _buildInfoTile('Wallet Balance', '₹${student['marketplace']['walletBalance']}'),
                            ]),
                          ],
                        ),
                      ),

                      // Tab 5: Financial Summary
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            _buildInfoGrid([
                              _buildInfoTile('Financial Health Score', '${student['financialSummary']['score']}/100'),
                              _buildInfoTile('Score Category', student['financialSummary']['scoreCategory']),
                              _buildInfoTile('Total Aid Received', '₹${student['financialSummary']['totalAidReceived']}'),
                              _buildInfoTile('Savings Rate', student['financialSummary']['savingsRate']),
                              _buildInfoTile('Aid Wallet Balance', '₹${student['financialSummary']['aidBalance']}'),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Modal Footer Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryLightGreen,
                            side: const BorderSide(color: primaryLightGreen),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _updateStudentStatus(student['id'], 'Active');
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: const Text('Activate'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _updateStudentStatus(student['id'], 'Blocked');
                          },
                          icon: const Icon(Icons.block_rounded, size: 18),
                          label: const Text('Block'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children.map((c) => SizedBox(width: 150, child: c)).toList(),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderMint)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String label, String status) {
    Color bg = status == 'Active' ? mintBg : Colors.red.shade50;
    Color fg = status == 'Active' ? primaryLightGreen : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderMint)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          const SizedBox(height: 4),
          Text(status, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: fg)),
        ],
      ),
    );
  }

  // --- Add Student Modal ---
  void _showAddStudentModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Add New Student', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryLightGreen),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _studentsList.add({
                    'id': DateTime.now().millisecondsSinceEpoch % 1000,
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'phone': phoneCtrl.text.isEmpty ? '+91 99999 88888' : phoneCtrl.text,
                    'rollNo': 'STU-2026-${_studentsList.length + 100}',
                    'department': 'Computer Engineering',
                    'batch': '2026-2030',
                    'regDate': '2026-09-06',
                    'status': 'Active',
                    'scholarships': [],
                    'fees': {'totalFee': 65000, 'paidFee': 0, 'pendingDues': 65000, 'lastPaymentTxn': 'NONE'},
                    'marketplace': {'itemsBought': 0, 'itemsListed': 0, 'itemsSold': 0, 'totalSpent': 0, 'totalEarned': 0, 'walletBalance': 0},
                    'financialSummary': {'score': 80, 'scoreCategory': 'Good', 'totalAidReceived': 0, 'savingsRate': '0%', 'aidBalance': 0},
                  });
                });
                Navigator.pop(dlgCtx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student "${nameCtrl.text}" saved!'), backgroundColor: primaryLightGreen));
              }
            },
            child: const Text('Save Student'),
          ),
        ],
      ),
    );
  }

  // --- Create Admin Modal ---
  void _showCreateAdminModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Create Admin Account', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Admin Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Admin Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryLightGreen),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _adminsList.add({
                    'id': DateTime.now().millisecondsSinceEpoch % 1000,
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'role': 'System Admin',
                    'userType': 1,
                    'phone': '+91 98888 77777',
                    'createdDate': '2026-09-06',
                  });
                });
                Navigator.pop(dlgCtx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admin "${nameCtrl.text}" created!'), backgroundColor: primaryLightGreen));
              }
            },
            child: const Text('Create Admin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      appBar: AppBar(
        backgroundColor: darkForest,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: primaryLightGreen, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Super Admin Portal', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text('Light Green Enterprise FinTech', style: GoogleFonts.inter(fontSize: 11, color: mintAccent)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadSuperAdminData),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),

      // Sidebar Drawer Navigation ONLY
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [darkForest, primaryLightGreen]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: mintAccent,
                child: Text(widget.adminName[0], style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkForest)),
              ),
              accountName: Text(widget.adminName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              accountEmail: Row(
                children: [
                  Text(widget.adminEmail, style: GoogleFonts.inter(fontSize: 12, color: mintAccent)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: secondaryEmerald, borderRadius: BorderRadius.circular(4)),
                    child: Text('SUPER ADMIN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: _activeCategory == 'Dashboard',
                    onTap: () {
                      setState(() {
                        _activeCategory = 'Dashboard';
                        _activeSubView = 'Overview';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.people_alt_outlined,
                    title: 'User Management',
                    category: 'User Management',
                    children: [
                      _buildSubMenuItem('All Students'),
                      _buildSubMenuItem('Active Students'),
                      _buildSubMenuItem('Blocked Students'),
                    ],
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Management',
                    category: 'Admin Management',
                    children: [
                      _buildSubMenuItem('All Admins'),
                      _buildSubMenuItem('Create Admin', isAction: true, onActionTap: _showCreateAdminModal),
                      _buildSubMenuItem('Edit Admin'),
                      _buildSubMenuItem('Delete Admin'),
                      _buildSubMenuItem('Reset Password'),
                    ],
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.school_outlined,
                    title: 'Scholarship Management',
                    category: 'Scholarship Management',
                    children: [
                      _buildSubMenuItem('Scholarships'),
                      _buildSubMenuItem('Applications'),
                      _buildSubMenuItem('Approvals'),
                      _buildSubMenuItem('Rejections'),
                    ],
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.storefront_outlined,
                    title: 'Marketplace Management',
                    category: 'Marketplace Management',
                    children: [
                      _buildSubMenuItem('All Listings'),
                      _buildSubMenuItem('Reported Listings'),
                      _buildSubMenuItem('Seller Management'),
                    ],
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    category: 'Analytics',
                    children: [
                      _buildSubMenuItem('Student Analytics'),
                      _buildSubMenuItem('Scholarship Analytics'),
                      _buildSubMenuItem('Marketplace Analytics'),
                      _buildSubMenuItem('Financial Reports'),
                    ],
                  ),

                  _buildSidebarExpansionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    category: 'Settings',
                    children: [
                      _buildSubMenuItem('Security'),
                      _buildSubMenuItem('Notifications'),
                      _buildSubMenuItem('General Settings'),
                    ],
                  ),

                  const Divider(color: borderMint),

                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.red),
                    title: Text('Logout', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryLightGreen))
          : RefreshIndicator(
              onRefresh: _loadSuperAdminData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Welcome Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryLightGreen, darkForest],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: primaryLightGreen.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome back, Sankalp 👋', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Campus FinTech Ecosystem • System Status: OPERATIONAL ✓', style: GoogleFonts.inter(fontSize: 12, color: mintAccent)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, color: secondaryEmerald, size: 10),
                                const SizedBox(width: 6),
                                Text('Live Sync', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Breadcrumb Sub-Header
                    Row(
                      children: [
                        Text(_activeCategory, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: darkForest)),
                        const Icon(Icons.chevron_right_rounded, color: textMuted),
                        Text(_activeSubView, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryLightGreen)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDynamicContent(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String title, required bool isSelected, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryLightGreen : textMuted),
      title: Text(title, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryLightGreen : textDark)),
      selected: isSelected,
      selectedTileColor: mintBg,
      onTap: onTap,
    );
  }

  Widget _buildSidebarExpansionTile({required IconData icon, required String title, required String category, required List<Widget> children}) {
    final bool isCategoryActive = _activeCategory == category;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isCategoryActive,
        leading: Icon(icon, color: isCategoryActive ? primaryLightGreen : textMuted),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: isCategoryActive ? FontWeight.bold : FontWeight.w500, color: isCategoryActive ? darkForest : textDark, fontSize: 14)),
        children: children,
      ),
    );
  }

  Widget _buildSubMenuItem(String subViewName, {bool isAction = false, VoidCallback? onActionTap}) {
    final bool isSelected = _activeCategory != 'Dashboard' && _activeSubView == subViewName;

    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Icon(isAction ? Icons.add_circle_outline_rounded : Icons.radio_button_unchecked_rounded, size: 14, color: isSelected ? primaryLightGreen : (isAction ? primaryLightGreen : textMuted)),
            const SizedBox(width: 8),
            Text(subViewName, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected || isAction ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryLightGreen : (isAction ? primaryLightGreen : textDark))),
          ],
        ),
        selected: isSelected,
        selectedTileColor: mintBg,
        onTap: () {
          if (onActionTap != null) {
            Navigator.pop(context);
            onActionTap();
          } else {
            String parentCategory = 'Dashboard';
            if (['All Students', 'Active Students', 'Blocked Students'].contains(subViewName)) parentCategory = 'User Management';
            if (['All Admins', 'Create Admin', 'Edit Admin', 'Delete Admin', 'Reset Password'].contains(subViewName)) parentCategory = 'Admin Management';
            if (['Scholarships', 'Applications', 'Approvals', 'Rejections'].contains(subViewName)) parentCategory = 'Scholarship Management';
            if (['All Listings', 'Reported Listings', 'Seller Management'].contains(subViewName)) parentCategory = 'Marketplace Management';
            if (['Student Analytics', 'Scholarship Analytics', 'Marketplace Analytics', 'Financial Reports'].contains(subViewName)) parentCategory = 'Analytics';
            if (['Security', 'Notifications', 'General Settings'].contains(subViewName)) parentCategory = 'Settings';

            setState(() {
              _activeCategory = parentCategory;
              _activeSubView = subViewName;
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildDynamicContent() {
    switch (_activeCategory) {
      case 'Dashboard':
        return _buildDashboardOverview();
      case 'User Management':
        return _buildUserManagementView();
      case 'Admin Management':
        return _buildAdminManagementView();
      case 'Scholarship Management':
        return _buildScholarshipManagementView();
      case 'Marketplace Management':
        return _buildMarketplaceManagementView();
      case 'Analytics':
        return _buildAnalyticsView();
      case 'Settings':
        return _buildSettingsView();
      default:
        return _buildDashboardOverview();
    }
  }

  // 1. Executive Dashboard Overview with Interactive Flowcharts & Financial Graphs
  Widget _buildDashboardOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7 Summary Metric Cards Grid
        LayoutBuilder(
          builder: (ctx, constraints) {
            final double cardWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildKpiCard('Total Students', '${_stats['totalStudents'] ?? 1234}', '+14.2%', Icons.school_outlined, cardWidth),
                _buildKpiCard('Total Admins', '${_stats['totalAdmins'] ?? 14}', '14 System', Icons.admin_panel_settings_outlined, cardWidth),
                _buildKpiCard('Total Scholarships', '${_stats['activeScholarships'] ?? 28}', '28 Programs', Icons.card_membership_outlined, cardWidth),
                _buildKpiCard('Total Applications', '${_stats['totalApplications'] ?? 286}', '+48 pending', Icons.assignment_outlined, cardWidth),
                _buildKpiCard('Marketplace Listings', '${_stats['totalMarketplaceListings'] ?? _stats['totalProducts'] ?? 156}', '+24 active', Icons.storefront_outlined, cardWidth),
                _buildKpiCard('Total Transactions', '${_stats['totalTransactions'] ?? 3890}', '+18.5%', Icons.swap_horiz_outlined, cardWidth),
                _buildKpiCard('Total Savings Generated', '₹${((_stats['totalSavingsGenerated'] ?? 485000) as num).toStringAsFixed(0)}', '+₹42.5K', Icons.account_balance_wallet_outlined, cardWidth),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Interactive Stage Application & Audit Pipeline Flow Chart Diagram
        _buildInteractivePipelineFlowchart(),

        const SizedBox(height: 24),

        // Interactive Monthly Disbursement Financial Graph
        _buildDisbursementBarChart(),

        const SizedBox(height: 24),

        // Transaction Distribution & Channel Breakdown
        _buildTransactionDistributionChart(),

        const SizedBox(height: 24),

        // Visual Analytics Progress Bar Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderMint),
            boxShadow: [
              BoxShadow(color: primaryLightGreen.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Scholarship Fund Allocation Breakdown', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                    child: Text('₹1.05 Lakhs Active Aid', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: primaryLightGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildProgressBar('State Merit Scholarships (45%)', 0.45, primaryLightGreen),
              const SizedBox(height: 10),
              _buildProgressBar('Need-Based Financial Assistance (35%)', 0.35, darkForest),
              const SizedBox(height: 10),
              _buildProgressBar('Tech Innovation Grants (20%)', 0.20, secondaryEmerald),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick Administrative Actions Bar
        Text('Quick Administrative Actions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryLightGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _showAddStudentModal,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add Student'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkForest, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _showCreateAdminModal,
                icon: const Icon(Icons.add_moderator_rounded, size: 18),
                label: const Text('Create Admin'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Interactive Flowchart Diagram Widget
  Widget _buildInteractivePipelineFlowchart() {
    final stages = [
      {'title': 'Draft', 'count': 35, 'percent': '100%', 'color': const Color(0xFF64748B), 'icon': Icons.edit_note_rounded},
      {'title': 'Submitted', 'count': 120, 'percent': '88%', 'color': const Color(0xFF2563EB), 'icon': Icons.send_rounded},
      {'title': 'Verification', 'count': 65, 'percent': '74%', 'color': const Color(0xFFF97316), 'icon': Icons.fact_check_rounded},
      {'title': 'Under Review', 'count': 40, 'percent': '52%', 'color': const Color(0xFF8B5CF6), 'icon': Icons.pending_actions_rounded},
      {'title': 'Approved', 'count': 20, 'percent': '38%', 'color': primaryLightGreen, 'icon': Icons.verified_rounded},
      {'title': 'Disbursed', 'count': 6, 'percent': '18%', 'color': darkForest, 'icon': Icons.account_balance_wallet_rounded},
    ];

    final activeStage = stages[_selectedStageIndex.clamp(0, stages.length - 1)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMint),
        boxShadow: [
          BoxShadow(
            color: primaryLightGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                      color: mintBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_tree_rounded, color: primaryLightGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit & Application Pipeline Flow Chart',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest),
                      ),
                      Text(
                        'Real-time conversion metrics across 6 stage milestones',
                        style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                child: Text('Live Pipeline Flow', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: primaryLightGreen)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(stages.length, (idx) {
                final st = stages[idx];
                final isSelected = _selectedStageIndex == idx;
                final Color stColor = st['color'] as Color;

                return Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedStageIndex = idx),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? stColor.withValues(alpha: 0.12) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? stColor : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: stColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(st['icon'] as IconData, size: 16, color: stColor),
                                const SizedBox(width: 6),
                                Text(
                                  st['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? stColor : textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${st['count']} Apps',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: stColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${st['percent']} Pass Rate',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: stColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (idx < stages.length - 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey[400]),
                            Text(
                              '${(((stages[idx + 1]['count'] as int) / (st['count'] as int)) * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: primaryLightGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (activeStage['color'] as Color).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (activeStage['color'] as Color).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: activeStage['color'] as Color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stage ${activeStage['title']}: ${activeStage['count']} student applications active. Conversion pass rate: ${activeStage['percent']}.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: textDark, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Monthly Financial Disbursement Visual Bar Chart Graph
  Widget _buildDisbursementBarChart() {
    final monthsData = [
      {'month': 'Jan', 'amount': 45.0, 'apps': 32},
      {'month': 'Feb', 'amount': 62.0, 'apps': 48},
      {'month': 'Mar', 'amount': 98.0, 'apps': 76},
      {'month': 'Apr', 'amount': 115.0, 'apps': 92},
      {'month': 'May', 'amount': 85.0, 'apps': 64},
      {'month': 'Jun', 'amount': 140.0, 'apps': 112},
    ];

    const double maxVal = 160.0;
    final selectedMonth = monthsData[_selectedMonthIndex.clamp(0, monthsData.length - 1)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMint),
        boxShadow: [
          BoxShadow(
            color: primaryLightGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.bar_chart_rounded, color: primaryLightGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Disbursement & Analytics Graph', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
                      Text('Monthly scholarship disbursement trajectory (in Thousands ₹)', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: mintAccent, borderRadius: BorderRadius.circular(12)),
                child: Text('+24.8% YoY Growth', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: darkForest)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 170,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(monthsData.length, (idx) {
                final item = monthsData[idx];
                final double amt = item['amount'] as double;
                final double heightRatio = amt / maxVal;
                final bool isSelected = _selectedMonthIndex == idx;

                return GestureDetector(
                  onTap: () => setState(() => _selectedMonthIndex = idx),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: darkForest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹${amt.toStringAsFixed(0)}K',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isSelected ? 34 : 26,
                        height: 120 * heightRatio,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isSelected
                                ? [primaryLightGreen, darkForest]
                                : [secondaryEmerald.withValues(alpha: 0.7), primaryLightGreen.withValues(alpha: 0.3)],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          boxShadow: isSelected
                              ? [BoxShadow(color: primaryLightGreen.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['month'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? primaryLightGreen : textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mintBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderMint),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights_rounded, size: 18, color: primaryLightGreen),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedMonth['month']} 2026 Metrics:',
                      style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: darkForest),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Disbursed ₹${(selectedMonth['amount'] as double).toStringAsFixed(0)}K across ${selectedMonth['apps']} verified applicants',
                      style: GoogleFonts.inter(fontSize: 11.5, color: textDark),
                    ),
                  ],
                ),
                Text(
                  'Avg: ₹${((selectedMonth['amount'] as double) * 1000 / (selectedMonth['apps'] as int)).toStringAsFixed(0)}/student',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: primaryLightGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Transaction Channel Breakdown
  Widget _buildTransactionDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMint),
        boxShadow: [
          BoxShadow(
            color: primaryLightGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FinTech Transaction Channel Distribution', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                child: Text('3,890 Total Txns', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: primaryLightGreen)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgressBar('Direct Scholarship Disbursements (62%)', 0.62, primaryLightGreen),
          const SizedBox(height: 10),
          _buildProgressBar('Campus Student Marketplace Payments (28%)', 0.28, secondaryEmerald),
          const SizedBox(height: 10),
          _buildProgressBar('Institute Tuition Fee Settlement (10%)', 0.10, darkForest),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, String badge, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMint),
        boxShadow: [
          BoxShadow(color: primaryLightGreen.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: primaryLightGreen, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: mintAccent, borderRadius: BorderRadius.circular(12)),
                child: Text(badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: darkForest)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
        ],
      ),
    );
  }

  // 2. User Management View
  Widget _buildUserManagementView() {
    List<Map<String, dynamic>> filteredStudents = _studentsList;
    if (_activeSubView == 'Active Students') filteredStudents = _studentsList.where((s) => s['status'] == 'Active').toList();
    if (_activeSubView == 'Blocked Students') filteredStudents = _studentsList.where((s) => s['status'] == 'Blocked').toList();

    if (_searchQuery.isNotEmpty) {
      filteredStudents = filteredStudents.where((s) {
        final q = _searchQuery.toLowerCase();
        return s['name'].toString().toLowerCase().contains(q) || s['email'].toString().toLowerCase().contains(q);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search student profile by name, email or roll no...',
                  prefixIcon: const Icon(Icons.search_rounded, color: primaryLightGreen),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderMint)),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryLightGreen, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              onPressed: _showAddStudentModal,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Student'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredStudents.length,
          itemBuilder: (ctx, idx) {
            final student = filteredStudents[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderMint)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: mintAccent,
                  child: Text(student['name'][0], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
                ),
                title: Text(student['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark)),
                subtitle: Text('${student['email']} • Roll: ${student['rollNo']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: primaryLightGreen, side: const BorderSide(color: primaryLightGreen)),
                  onPressed: () => _showStudentProfileModal(student),
                  child: const Text('View 5-Tab Profile'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 3. Admin Management View
  Widget _buildAdminManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('System Admin Directory', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primaryLightGreen),
              onPressed: _showCreateAdminModal,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Admin'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: _adminsList.map((adm) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderMint)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: darkForest,
                    child: Text(adm['name'][0], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(adm['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark)),
                        Text('${adm['email']} • ${adm['phone']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(adm['role'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: darkForest)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 4. Table View Scholarship Management
  Widget _buildScholarshipManagementView() {
    List<Map<String, dynamic>> filteredApps = _applicationsList;
    if (_activeSubView == 'Approvals') filteredApps = _applicationsList.where((a) => a['status'] == 'Approved').toList();
    if (_activeSubView == 'Rejections') filteredApps = _applicationsList.where((a) => a['status'] == 'Rejected').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scholarship Programs & Applications', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
        const SizedBox(height: 16),

        // Active Programs Summary
        Text('Published Programs', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 8),
        Column(
          children: _scholarshipsList.map((sch) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderMint)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sch['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
                      Text('Amount: ${sch['amount']} • Deadline: ${sch['deadline']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                    child: Text('${sch['totalApplications']} Applicants', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: primaryLightGreen)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        Text('Student Applications Table', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 8),

        // Table View of Applications
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderMint)),
          child: Column(
            children: filteredApps.map((app) {
              return ListTile(
                title: Text('${app['studentName']} (${app['appId']})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${app['scholarshipName']} • Amount: ₹${app['amount']} • GPA: ${app['gpa']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(6)),
                      child: Text(app['status'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: primaryLightGreen)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: primaryLightGreen),
                      onPressed: () {
                        setState(() => app['status'] = 'Approved');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated to Approved!')));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                      onPressed: () {
                        setState(() => app['status'] = 'Rejected');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated to Rejected.')));
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 5. Marketplace Management View
  Widget _buildMarketplaceManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marketplace Listings Moderation', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
        const SizedBox(height: 14),
        Column(
          children: _marketplaceProducts.map((prod) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderMint)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: mintBg, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.shopping_bag_outlined, color: primaryLightGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prod['title'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark)),
                        Text('Seller: ${prod['sellerName']} • ₹${prod['price']}', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                    onPressed: () {
                      setState(() => _marketplaceProducts.removeWhere((p) => p['id'] == prod['id']));
                    },
                    child: const Text('Remove Listing'),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 6. Analytics View
  Widget _buildAnalyticsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enterprise Light Green Analytics', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderMint)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scholarship Analytics & Fund Allocation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: darkForest)),
              const SizedBox(height: 12),
              _buildProgressBar('State Merit Grants (45%)', 0.45, primaryLightGreen),
              const SizedBox(height: 10),
              _buildProgressBar('Need-Based Assistance (35%)', 0.35, darkForest),
              const SizedBox(height: 10),
              _buildProgressBar('Innovation Grants (20%)', 0.20, secondaryEmerald),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: textDark)),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: val, backgroundColor: mintBg, color: col, minHeight: 10),
      ],
    );
  }

  // 7. Settings View
  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Settings & Security', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: darkForest)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderMint)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Maintenance Mode', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: const Text('Disable student portal during system updates'),
                value: false,
                activeTrackColor: primaryLightGreen,
                onChanged: (val) {},
              ),
              const Divider(height: 1, color: borderMint),
              SwitchListTile(
                title: Text('Enforce 2FA Security', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: const Text('Require 2FA authentication for Super Admin'),
                value: true,
                activeTrackColor: primaryLightGreen,
                onChanged: (val) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
