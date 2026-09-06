import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'scholarship_apply_stepper_screen.dart';

class ScholarshipScreen extends StatefulWidget {
  final String userName;
  final String studentId;

  const ScholarshipScreen({
    super.key,
    this.userName = 'Hitija Mhatre',
    this.studentId = 'CMP-2026-8910',
  });

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter State
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedTrackerFilter = 'All';
  String? _expandedAppId;

  // Smart Eligibility Checker State
  String _selectedCourse = 'Degree (B.Tech / B.E.)';
  String _selectedDept = 'Computer Science & Engineering';
  String _selectedYear = '3rd Year';
  double _cgpaInput = 8.5;
  double _incomeInput = 3.5; // in Lakhs
  bool _eligibilityChecked = false;
  bool _isEligibleResult = true;

  // Notification Reminders State
  bool _remindersEnabled = true;

  // Light Green FinTech Palette (#10B981 / #059669 / #ECFDF5)
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color emeraldAccent = Color(0xFF059669);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Digital Document Vault Manager
  final List<Map<String, dynamic>> _documentVault = [
    {
      'id': 'DOC-01',
      'title': 'Semester 5 Official Marksheet / Transcript',
      'category': 'Academic Record',
      'uploadDate': '10 Aug 2026',
      'status': 'VERIFIED BY REGISTRAR',
      'isVerified': true,
      'fileSize': '1.2 MB PDF',
      'icon': Icons.description_rounded,
    },
    {
      'id': 'DOC-02',
      'title': 'Tahsildar Income Certificate (Valid 2026-27)',
      'category': 'Financial Proof',
      'uploadDate': '12 Aug 2026',
      'status': 'VERIFIED BY MAHADBT',
      'isVerified': true,
      'fileSize': '850 KB PDF',
      'icon': Icons.request_quote_rounded,
    },
    {
      'id': 'DOC-03',
      'title': 'Maharashtra Domicile & Caste Certificate',
      'category': 'State Verification',
      'uploadDate': '08 Aug 2026',
      'status': 'VERIFIED BY GOVT',
      'isVerified': true,
      'fileSize': '1.8 MB PDF',
      'icon': Icons.verified_user_rounded,
    },
    {
      'id': 'DOC-04',
      'title': 'Campus Student ID Card & Aadhaar',
      'category': 'Identity Proof',
      'uploadDate': '05 Aug 2026',
      'status': 'VERIFIED',
      'isVerified': true,
      'fileSize': '2.1 MB PDF',
      'icon': Icons.badge_rounded,
    },
    {
      'id': 'DOC-05',
      'title': 'Linked Bank Passbook (HDFC Bank)',
      'category': 'Banking & Disbursal',
      'uploadDate': '14 Aug 2026',
      'status': 'VERIFIED FOR CREDIT',
      'isVerified': true,
      'fileSize': '940 KB PDF',
      'icon': Icons.account_balance_rounded,
    },
  ];

  // Applied Scholarships (With 7-Stage Visual Audit Timeline Progress)
  final List<Map<String, dynamic>> _myApplications = [
    {
      'id': 'MAHA-2026-8910',
      'title': 'MSBTE Diploma & Degree Merit Scholarship',
      'provider': 'Maharashtra State Board of Technical Education (MSBTE)',
      'amount': '₹25,000',
      'appliedDate': '15 Aug 2026, 10:30 AM',
      'status': 'Approved & Credited',
      'statusColor': emeraldAccent,
      'stageIndex': 6, // Stage 7: Amount Credited (0-indexed: 6)
      'bankAccount': 'HDFC Bank •••• 4892 (Hitija Mhatre)',
      'disbursedDate': '01 Sep 2026',
      'txnId': 'TXN98421092482',
      'feeOffset': '₹25,000 Direct Fee Offset',
      'boardTag': 'MSBTE Official',
      'stepsDetail': [
        {
          'name': 'Draft Created',
          'time': '14 Aug 2026',
          'status': 'Completed',
          'by': 'Applicant',
        },
        {
          'name': 'Application Submitted on MahaDBT',
          'time': '15 Aug 2026, 10:30 AM',
          'status': 'Completed',
          'by': 'Applicant',
        },
        {
          'name': 'Institute Registrar Verification',
          'time': '18 Aug 2026, 02:15 PM',
          'status': 'Completed',
          'by': 'Campus Officer',
        },
        {
          'name': 'State DHE Portal Scrutiny',
          'time': '21 Aug 2026, 04:00 PM',
          'status': 'Completed',
          'by': 'Scrutiny Officer',
        },
        {
          'name': 'MSBTE Board Final Approval',
          'time': '24 Aug 2026, 11:00 AM',
          'status': 'Approved',
          'by': 'MSBTE Desk',
        },
        {
          'name': 'Treasury Fund Release Order',
          'time': '29 Aug 2026, 03:20 PM',
          'status': 'Released',
          'by': 'State Treasury',
        },
        {
          'name': 'Direct Bank Credit & Fee Reduction',
          'time': '01 Sep 2026, 09:45 AM',
          'status': 'Credited ✓',
          'by': 'Bank Treasury',
        },
      ],
    },
    {
      'id': 'MAHA-2026-9214',
      'title': 'Rajarshi Chhatrapati Shahu Maharaj Fee Concession (EBC)',
      'provider': 'Directorate of Higher Education, Maharashtra',
      'amount': '₹19,000',
      'appliedDate': '28 Aug 2026, 04:20 PM',
      'status': 'Under Review',
      'statusColor': const Color(0xFFD97706),
      'stageIndex': 3, // Stage 4: Under Review
      'bankAccount': 'HDFC Bank •••• 4892 (Verified)',
      'disbursedDate': 'Expected 15 Sep 2026',
      'txnId': 'Pending Approval',
      'feeOffset': '50% Tuition Fee Subsidized',
      'boardTag': 'MahaDBT EBC',
      'stepsDetail': [
        {
          'name': 'Draft Created',
          'time': '27 Aug 2026',
          'status': 'Completed',
          'by': 'Applicant',
        },
        {
          'name': 'Application Submitted',
          'time': '28 Aug 2026, 04:20 PM',
          'status': 'Completed',
          'by': 'Applicant',
        },
        {
          'name': 'Scrutiny Officer Doc Check',
          'time': '30 Aug 2026, 01:10 PM',
          'status': 'Completed',
          'by': 'Nodal Officer',
        },
        {
          'name': 'State DHE Under Review',
          'time': 'In Progress',
          'status': 'Under Review',
          'by': 'DHE Portal Desk',
        },
        {
          'name': 'Final Sanction Clearance',
          'time': 'Scheduled',
          'status': 'Pending',
          'by': 'Sanction Board',
        },
        {
          'name': 'Disbursement Release',
          'time': 'Scheduled',
          'status': 'Pending',
          'by': 'Treasury',
        },
        {
          'name': 'Bank Credit & Fee Waiver',
          'time': 'Scheduled',
          'status': 'Pending',
          'by': 'Bank Treasury',
        },
      ],
    },
  ];

  // Comprehensive List of All Scholarships
  final List<Map<String, dynamic>> _availableScholarships = [
    {
      'id': 'SCH-AVAIL-MSBTE',
      'title': 'MSBTE Diploma & Degree Merit Scholarship',
      'provider': 'Maharashtra State Board of Technical Education',
      'amount': '₹25,000',
      'deadline': '30 Sep 2026',
      'daysLeft': 25,
      'criteria': 'Marks > 80% • Diploma / Degree Engg Students',
      'description':
          'Official State Technical Education Board scholarship for meritorious engineering & technology students across Maharashtra.',
      'category': 'MSBTE Govt',
      'matchScore': 98,
      'feeImpactText': 'Covers ₹25,000 of Tuition Fee',
      'boardTag': 'MSBTE Board',
      'portalUrl': 'https://msbte.org.in/',
      'requiredDocs': [
        'Aadhaar Card',
        'Semester Marksheet',
        'Income Certificate',
        'Bank Passbook',
      ],
    },
    {
      'id': 'SCH-AVAIL-EBC',
      'title': 'Rajarshi Chhatrapati Shahu Maharaj Concession (EBC)',
      'provider': 'Directorate of Higher Education (MahaDBT)',
      'amount': '₹19,000',
      'deadline': '15 Oct 2026',
      'daysLeft': 40,
      'criteria': 'Annual Income < ₹8.0 Lakhs • General / EWS / OBC',
      'description':
          '50% Tuition and Exam Fee concession for Economically Backward Class (EBC) students admitted through CAP rounds.',
      'category': 'MahaDBT Govt',
      'matchScore': 96,
      'feeImpactText': '50% Tuition Fee Subsidy (₹19,000)',
      'boardTag': 'MahaDBT Portal',
      'portalUrl': 'https://mahadbt.maharashtra.gov.in/',
      'requiredDocs': [
        'Income Certificate',
        'Aadhaar Card',
        'CAP Allotment Letter',
        'Domicile Certificate',
      ],
    },
    {
      'id': 'SCH-AVAIL-PUNJABRAO',
      'title': 'Dr. Punjabrao Deshmukh Hostel Maintenance Allowance',
      'provider': 'Department of Agriculture & Tech (Maharashtra)',
      'amount': '₹30,000',
      'deadline': '25 Sep 2026',
      'daysLeft': 20,
      'criteria': 'Children of Small Farmers / Income < ₹8 Lakhs',
      'description':
          'Hostel accommodation and monthly living maintenance allowance for students residing in campus/city hostels.',
      'category': 'Hostel Grant',
      'matchScore': 90,
      'feeImpactText': 'Direct Hostel Fee Waiver (₹30,000)',
      'boardTag': 'State Govt',
      'portalUrl': 'https://mahadbt.maharashtra.gov.in/',
      'requiredDocs': [
        'Hostel Fee Receipt',
        'Alpabhudharak Certificate',
        'Aadhaar Card',
      ],
    },
    {
      'id': 'SCH-AVAIL-POSTMATRIC',
      'title': 'Post-Matric Scholarship for SC / ST / OBC / VJNTA',
      'provider': 'Social Justice & Special Assistance Dept (MahaDBT)',
      'amount': '₹38,000',
      'deadline': '10 Nov 2026',
      'daysLeft': 65,
      'criteria': 'Category Reserved Students • Maharashtra Resident',
      'description':
          '100% tuition & maintenance fee reimbursement granted by State Govt for reserved category students.',
      'category': 'MahaDBT Govt',
      'matchScore': 92,
      'feeImpactText': 'Covers 100% Tuition Fee (₹38,000)',
      'boardTag': 'MahaDBT Portal',
      'portalUrl': 'https://mahadbt.maharashtra.gov.in/',
      'requiredDocs': [
        'Caste Certificate',
        'Caste Validity',
        'Income Certificate',
        'Marksheet',
      ],
    },
    {
      'id': 'SCH-AVAIL-CSSS',
      'title': 'Central Sector Scheme of Scholarships (CSSS)',
      'provider': 'Ministry of Education (Govt of India)',
      'amount': '₹20,000',
      'deadline': '31 Oct 2026',
      'daysLeft': 55,
      'criteria': 'Top 20th Percentile in 12th Board Exams',
      'description':
          'Central Government Merit Scholarship supporting undergraduate studies across recognized universities.',
      'category': 'Merit',
      'matchScore': 85,
      'feeImpactText': 'Covers ₹20,000 Annual Tuition',
      'boardTag': 'Central Govt',
      'portalUrl': 'https://scholarships.gov.in/',
      'requiredDocs': ['12th Marksheet', 'Aadhaar Card', 'Bank Passbook'],
    },
    {
      'id': 'SCH-AVAIL-TATA',
      'title': 'Tata Trusts Higher Education Fellowship',
      'provider': 'Tata Endowment Trust Foundation',
      'amount': '₹50,000',
      'deadline': '20 Nov 2026',
      'daysLeft': 75,
      'criteria': 'Engg / Tech Undergraduates • CGPA > 8.0',
      'description':
          'Prestigious private trust fellowship awarding tuition support & mentorship for promising engineers.',
      'category': 'Private Trust',
      'matchScore': 94,
      'feeImpactText': 'Covers Full Semester Fee + Laptop Grant',
      'boardTag': 'Tata Trust',
      'portalUrl': 'https://www.tatatrusts.org/',
      'requiredDocs': [
        'College Bonafide',
        'Transcript (All Sems)',
        'Family Income Proof',
        'SOP Essay',
      ],
    },
  ];

  // Disbursed Wallet Transactions
  final List<Map<String, dynamic>> _walletTransactions = [
    {
      'id': 'TXN98421092482',
      'title': 'MSBTE Merit Scholarship Credit',
      'scholarship': 'MSBTE Diploma & Degree Merit Scholarship',
      'amount': '₹25,000',
      'date': '01 Sep 2026, 09:45 AM',
      'status': 'Credited to HDFC Bank (•••• 4892)',
      'isCredit': true,
    },
    {
      'id': 'TXN87210492104',
      'title': 'Fee Offset Adjustment',
      'scholarship': 'Tuition Subsidy Direct Credit',
      'amount': '₹25,000',
      'date': '01 Sep 2026, 10:00 AM',
      'status': 'Applied directly to Autumn Semester Fee',
      'isCredit': false,
    },
  ];

  // Financial Metrics
  final int _grossTuitionFee = 75000;
  int get _totalReceivedAmount {
    int sum = 0;
    for (var app in _myApplications) {
      if (app['status'] == 'Approved & Credited') {
        final valStr = (app['amount'] as String)
            .replaceAll('₹', '')
            .replaceAll(',', '');
        sum += int.tryParse(valStr) ?? 0;
      }
    }
    return sum;
  }

  int get _netFeeRemaining => _grossTuitionFee - _totalReceivedAmount;
  double get _feeReductionPercent =>
      (_totalReceivedAmount / _grossTuitionFee) * 100;

  // 7-Stage Pipeline
  final List<String> _pipelineStages = [
    'Draft',
    'Submitted',
    'Verification',
    'Under Review',
    'Approved',
    'Fund Released',
    'Amount Credited',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Top Segmented Navigation Tabs
            _buildTopTabBar(),

            // Clean Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildScholarshipsTab(),
                  _buildApplicationsTab(),
                  _buildWalletTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP SEGMENTED TAB BAR
  // ==========================================
  Widget _buildTopTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Discover'),
            Tab(text: 'Tracker'),
            Tab(text: 'Wallet'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: DASHBOARD VIEW
  // ==========================================
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Scholarship Summary Card
          _buildMainScholarshipSummaryCard(),
          const SizedBox(height: 18),

          // Statistics Overview Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics Overview',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => _openDocumentVaultModal(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_special_rounded,
                      size: 15,
                      color: primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Doc Vault',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatisticsGrid(),
          const SizedBox(height: 20),

          // Upcoming Deadlines Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                        const Icon(
                          Icons.timer_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upcoming Application Deadlines',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _openNotificationModal(),
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDeadlineRow(
                  'MSBTE Merit Scholarship',
                  '30 Sep 2026',
                  '25 Days Left',
                  primaryGreen,
                ),
                const Divider(height: 18),
                _buildDeadlineRow(
                  'Dr. Punjabrao Deshmukh Hostel',
                  '25 Sep 2026',
                  '20 Days Left',
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recommended Schemes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Schemes',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  _tabController.animateTo(1);
                },
                child: Text(
                  'View All (${_availableScholarships.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              final sch = _availableScholarships[index];
              return _buildScholarshipCard(sch);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN SCHOLARSHIP SUMMARY CARD
  // ==========================================
  Widget _buildMainScholarshipSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C3A), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Scholarship Received',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha(220),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Active & Disbursed ✓',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${_totalReceivedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: goldLight,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Credited directly to HDFC Bank (•••• 4892) & Fee Account',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withAlpha(190),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openSmartEligibilityDialog(),
                  icon: const Icon(
                    Icons.bolt_rounded,
                    size: 15,
                    color: primaryGreen,
                  ),
                  label: Text(
                    'Check Eligibility',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldAccent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  icon: const Icon(
                    Icons.explore_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Browse All',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STATISTICS CARDS GRID
  // ==========================================
  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: [
        _buildStatCard(
          title: 'Available Schemes',
          value: '${_availableScholarships.length}',
          icon: Icons.explore_rounded,
          color: const Color(0xFF2563EB),
          bgLight: const Color(0xFFEFF6FF),
        ),
        _buildStatCard(
          title: 'Applied Schemes',
          value: '${_myApplications.length}',
          icon: Icons.assignment_turned_in_rounded,
          color: const Color(0xFFD97706),
          bgLight: const Color(0xFFFFFBEB),
        ),
        _buildStatCard(
          title: 'Approved Schemes',
          value:
              '${_myApplications.where((a) => a['status'] == 'Approved & Credited').length}',
          icon: Icons.check_circle_rounded,
          color: emeraldAccent,
          bgLight: const Color(0xFFECFDF5),
        ),
        _buildStatCard(
          title: 'Pending Applications',
          value:
              '${_myApplications.where((a) => a['status'] == 'Under Review').length}',
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFF9333EA),
          bgLight: const Color(0xFFFAF5FF),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgLight,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bgLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: DISCOVER
  // ==========================================
  Widget _buildScholarshipsTab() {
    final filtered = _availableScholarships.where((s) {
      final matchesCat =
          _selectedCategory == 'All' || s['category'] == _selectedCategory;
      final matchesSearch =
          s['title'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          s['provider'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          s['criteria'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCat && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by Scholarship Name, MahaDBT, MSBTE...',
              prefixIcon: const Icon(Icons.search_rounded, color: primaryGreen),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: goldAccent.withAlpha(80)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children:
                  [
                    'All',
                    'MSBTE Govt',
                    'MahaDBT Govt',
                    'Hostel Grant',
                    'Private Trust',
                    'Merit',
                  ].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        selectedColor: primaryGreen,
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSel ? primaryGreen : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: goldLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldAccent, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: goldAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _eligibilityChecked
                            ? (_isEligibleResult
                                  ? 'Smart Eligibility: 98% Match ✓'
                                  : 'Smart Eligibility: Conditional Match')
                            : 'Smart Eligibility Filter Active',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      Text(
                        'Calculate exact eligibility based on Marks & Income',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _openSmartEligibilityDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Run Check',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Available Scholarships (${filtered.length})',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final sch = filtered[index];
              return _buildScholarshipCard(sch);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: TRACKER (7-STAGE TIMELINE)
  // ==========================================
  Widget _buildApplicationsTab() {
    final filteredApps = _myApplications.where((app) {
      if (_selectedTrackerFilter == 'All') return true;
      if (_selectedTrackerFilter == 'Approved') {
        return app['status'].toString().contains('Approved');
      }
      if (_selectedTrackerFilter == 'Under Review') {
        return app['status'].toString().contains('Review') || app['status'].toString().contains('Pending');
      }
      if (_selectedTrackerFilter == 'Submitted') {
        return app['status'].toString().contains('Submitted');
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: goldAccent.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Application Tracker',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track all 7 stages from Draft to Bank Credit',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tracker Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Submitted', 'Under Review', 'Approved'].map((flt) {
                final isSel = _selectedTrackerFilter == flt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(flt),
                    selected: isSel,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTrackerFilter = flt;
                      });
                    },
                    selectedColor: primaryGreen,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSel ? primaryGreen : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'My Active Submissions (${filteredApps.length})',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          filteredApps.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 42, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text(
                        'No Applications Found',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Go to Discover tab to browse schemes and fill application forms.',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    final isExpanded = _expandedAppId == app['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isExpanded ? primaryGreen : Colors.grey[200]!,
                          width: isExpanded ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            title: Text(
                              app['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3),
                                Text(
                                  app['provider'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (app['statusColor'] as Color)
                                            .withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        app['status'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: app['statusColor'] as Color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      app['amount'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: goldAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: primaryGreen,
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandedAppId = isExpanded
                                      ? null
                                      : (app['id'] as String);
                                });
                              },
                            ),
                          ),

                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '7-Stage Audit Timeline Progress',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: primaryGreen,
                                        ),
                                      ),
                                      Text(
                                        'Ref: ${app['id']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  _build7StageVisualTimeline(
                                    app['stageIndex'] as int,
                                  ),
                                  const SizedBox(height: 16),

                                  Column(
                                    children: List.generate(
                                      (app['stepsDetail'] as List).length,
                                      (sIdx) {
                                        final step =
                                            (app['stepsDetail'] as List)[sIdx];
                                        final isDone =
                                            sIdx <= (app['stageIndex'] as int);
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Icon(
                                                  isDone
                                                      ? Icons.check_circle_rounded
                                                      : Icons
                                                            .radio_button_unchecked_rounded,
                                                  size: 16,
                                                  color: isDone
                                                      ? primaryGreen
                                                      : Colors.grey[400],
                                                ),
                                                if (sIdx <
                                                    (app['stepsDetail'] as List)
                                                            .length -
                                                        1)
                                                  Container(
                                                    width: 2,
                                                    height: 22,
                                                    color: isDone
                                                        ? primaryGreen
                                                        : Colors.grey[300],
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    step['name'] as String,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.5,
                                                      fontWeight: isDone
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isDone
                                                          ? AppColors.textPrimary
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${step['time']} • Officer: ${step['by']}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _openSubmittedFormDetailsModal(app),
                                          icon: const Icon(
                                            Icons.visibility_rounded,
                                            size: 14,
                                            color: primaryGreen,
                                          ),
                                          label: Text(
                                            'View Form & Docs',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: primaryGreen,
                                              width: 1.2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _openApplicationSlipModal(app),
                                          icon: const Icon(
                                            Icons.receipt_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Download Slip',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryGreen,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: WALLET & FEE IMPACT
  // ==========================================
  Widget _buildWalletTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Card with Quick Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D5C3A), Color(0xFF044E2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: goldAccent, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scholarship Earnings Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: goldAccent.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Verified Account ✓',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: goldAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '₹${_totalReceivedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Total Disbursed & Credited to Date',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white70,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Linked Account: HDFC Bank •••• 4892 (${widget.userName})',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openTransferToBankModal(),
                        icon: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: primaryGreen,
                        ),
                        label: Text(
                          'Transfer Bank',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldAccent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openPayFeeModal(),
                        icon: const Icon(
                          Icons.school_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Pay College Fee',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _openReceiptModal(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(50)),
                        ),
                        child: const Icon(
                          Icons.receipt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fee Impact Statement Card
          Text(
            'Fee Impact Statement',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: goldAccent.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeeImpactCol(
                      'Total College Fee',
                      '₹${_grossTuitionFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      AppColors.textPrimary,
                    ),
                    _buildFeeImpactCol(
                      'Scholarship Amount',
                      '₹${_totalReceivedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      primaryGreen,
                    ),
                    _buildFeeImpactCol(
                      'Remaining Fee',
                      '₹${_netFeeRemaining.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      const Color(0xFFD97706),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fee Reduction Percentage',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_feeReductionPercent.toStringAsFixed(1)}% Subsidized',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_totalReceivedAmount / _grossTuitionFee).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPayFeeModal(),
                    icon: const Icon(
                      Icons.payment_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Pay Net Remaining Fee (₹${_netFeeRemaining.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Disbursed Transactions History Header & List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disbursed Transactions History',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => _openReceiptModal(),
                child: Text(
                  'View All Slips',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _walletTransactions.length,
            itemBuilder: (context, index) {
              final txn = _walletTransactions[index];
              final isCredit = txn['isCredit'] as bool;
              return InkWell(
                onTap: () => _openTransactionDetailsModal(txn),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? primaryGreen.withAlpha(20)
                              : Colors.amber.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.swap_horiz_rounded,
                          color: isCredit ? primaryGreen : Colors.amber[800],
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${txn['date']} • ${txn['id']}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            txn['amount'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isCredit
                                  ? primaryGreen
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Completed ✓',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: emeraldAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: ANALYTICS
  // ==========================================
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D5C3A), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scholarship Analytics & ROI',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Statistical breakdown of your application success rate',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnalyticsStat(
                      'Total Applications',
                      '${_myApplications.length}',
                    ),
                    _buildAnalyticsStat(
                      'Approved',
                      '${_myApplications.where((a) => a['status'] == 'Approved & Credited').length}',
                    ),
                    _buildAnalyticsStat('Approval Rate', '50.0%'),
                    _buildAnalyticsStat('Total Value', '₹25K'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Application Status Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildAnalyticsBarRow(
                  'Approved & Credited',
                  0.50,
                  primaryGreen,
                  '1 Scheme (50%)',
                ),
                const SizedBox(height: 12),
                _buildAnalyticsBarRow(
                  'Under Review',
                  0.50,
                  const Color(0xFFD97706),
                  '1 Scheme (50%)',
                ),
                const SizedBox(height: 12),
                _buildAnalyticsBarRow(
                  'Draft / Pending',
                  0.0,
                  Colors.blue,
                  '0 Schemes (0%)',
                ),
                const SizedBox(height: 12),
                _buildAnalyticsBarRow(
                  'Rejected',
                  0.0,
                  const Color(0xFFDC2626),
                  '0 Schemes (0%)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: goldLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: goldAccent),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Vault Readiness: 100%',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      Text(
                        'All 5 essential documents are verified and ready for instant auto-attachment.',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGET BUILDERS
  // ==========================================
  Widget _buildDeadlineRow(
    String title,
    String date,
    String daysLeft,
    Color badgeColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Deadline: $date',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor, width: 1),
          ),
          child: Text(
            daysLeft,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> sch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldAccent.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    sch['boardTag'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${sch['matchScore']}% Match',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sch['title'] as String,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sch['provider'] as String,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grant Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      sch['amount'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Application Deadline',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      sch['deadline'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openApplySchemeModal(sch),
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Apply Scheme',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build7StageVisualTimeline(int currentStage) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_pipelineStages.length, (idx) {
          final isCompleted = idx <= currentStage;
          final isCurrent = idx == currentStage;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isCompleted ? primaryGreen : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? goldAccent
                            : (isCompleted ? primaryGreen : Colors.grey[400]!),
                        width: isCurrent ? 2.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 15,
                            )
                          : Text(
                              '${idx + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _pipelineStages[idx],
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent ? primaryGreen : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (idx < _pipelineStages.length - 1)
                Container(
                  width: 20,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: idx < currentStage ? primaryGreen : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFeeImpactCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: goldAccent,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildAnalyticsBarRow(
    String label,
    double percent,
    Color color,
    String countText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              countText,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 9,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODALS & DIALOGS
  // ==========================================
  // ==========================================
  // APPLY SCHEME OPTIONS & OFFICIAL PORTAL MODALS
  // ==========================================
  void _openApplySchemeModal(Map<String, dynamic> sch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      sch['boardTag'] as String,
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                  ),
                  Text(
                    sch['amount'] as String,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: goldAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                sch['title'] as String,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                sch['provider'] as String,
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // Option 1: Fill Interactive Form in App
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _openScholarshipApplicationFormModal(sch);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryGreen.withAlpha(12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fill Application Form in App',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                            ),
                            Text(
                              'Auto-attach verified Vault documents, CGPA & sync live 7-Stage Tracker',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Open Official Portal Website
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _openOfficialPortalWebView(sch);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: goldLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: goldAccent, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: goldAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.language_rounded, color: primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open Official Website Portal',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                            ),
                            Text(
                              'Launch ${(sch['portalUrl'] as String?) ?? 'MahaDBT / NSP Site'} with auto-copy PRN & credentials',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: goldAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 3: View Full Scheme Overview
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _openScholarshipDetailsModal(sch);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Scheme Overview & Guidelines',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Read full eligibility rules, criteria & required document checklists',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  },
);
}

  void _openOfficialPortalWebView(Map<String, dynamic> sch) {
    final portalUrl = (sch['portalUrl'] as String?) ?? 'https://mahadbt.maharashtra.gov.in/';
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 580),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Government Portal',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                          Text(
                            portalUrl,
                            style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: goldLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: goldAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key_rounded, color: primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PRN: ${widget.studentId} • Vault Verified ✓',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PRN & Credentials copied to clipboard!'), backgroundColor: primaryGreen),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 12),
                        label: Text('Copy', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.public_rounded, size: 48, color: primaryGreen),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connecting to ${sch['boardTag']}',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Official portal link:\n$portalUrl',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded, size: 12, color: primaryGreen),
                              const SizedBox(width: 6),
                              Text(
                                '256-Bit SSL Encrypted Govt Site',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openScholarshipApplicationFormModal(sch);
                        },
                        icon: const Icon(Icons.assignment_outlined, size: 14, color: primaryGreen),
                        label: Text('Fill Form in App', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${sch['boardTag']} official website ($portalUrl)...'),
                              backgroundColor: primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_browser_rounded, size: 14, color: Colors.white),
                        label: Text('Launch Browser', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openScholarshipDetailsModal(Map<String, dynamic> sch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGreen.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sch['boardTag'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sch['matchScore']}% Eligibility Match',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    sch['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sch['provider'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: goldLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goldAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scholarship Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              sch['amount'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: goldAccent,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Closing Deadline',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              sch['deadline'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sch['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Required Documents (Auto-Attachable)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children:
                        ((sch['requiredDocs'] as List<String>?) ??
                                ['Aadhaar Card', 'Income Proof'])
                            .map((doc) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: primaryGreen,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      doc,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Vault Ready ✓',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                  ),
                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openScholarshipApplicationFormModal(sch);
                      },
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Fill Official Application Form',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleExternalWebsiteScholarship(Map<String, dynamic> sch) async {
    final String urlStr = sch['portalUrl'] ?? sch['externalWebsiteUrl'] ?? 'https://mahadbt.maharashtra.gov.in';
    final String websiteName = sch['externalWebsiteName'] ?? sch['boardTag'] ?? 'Official Portal';
    final String websiteStatus = sch['externalWebsiteStatus'] ?? 'Portal Active & Accepting Applications';
    final String nowStr = '${DateTime.now().day} Sep 2026, 11:14 AM';

    // 1. Log visit to backend API
    ApiService.logExternalWebsiteVisit(
      studentId: 101,
      scholarshipId: sch['id'] is int ? sch['id'] : 1,
      websiteName: websiteName,
      websiteUrl: urlStr,
    );

    // 2. Add or update in local My Applications list
    setState(() {
      final existingIdx = _myApplications.indexWhere((a) => a['title'] == sch['title']);
      if (existingIdx >= 0) {
        _myApplications[existingIdx]['lastOpenedDate'] = nowStr;
        _myApplications[existingIdx]['externalWebsiteStatus'] = websiteStatus;
      } else {
        _myApplications.insert(0, {
          'id': 'EXT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'title': sch['title'],
          'provider': sch['provider'],
          'amount': sch['amount'],
          'appliedDate': nowStr,
          'application_status': 'External Portal Visited',
          'applicationMode': 'EXTERNAL_WEBSITE',
          'externalWebsiteName': websiteName,
          'externalWebsiteUrl': urlStr,
          'externalWebsiteStatus': websiteStatus,
          'lastOpenedDate': nowStr,
          'statusColor': const Color(0xFF2563EB),
          'remarks': 'User redirected to official website portal ($websiteName) to complete application.',
        });
      }
    });

    // 3. Try launching browser
    try {
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (!mounted) return;

    // 4. Display External Website Modal in-app
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.open_in_new_rounded, color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'External Website Portal',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                      Text(
                        websiteName,
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              sch['title'] ?? '',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Official Website Name:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      Flexible(
                        child: Text(websiteName, textAlign: TextAlign.right, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Website Status:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                        child: Text(websiteStatus, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last Opened Date:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      Text(nowStr, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete your scholarship application process on the official portal. Application progress and website visits are tracked automatically inside the app.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  try {
                    final uri = Uri.parse(urlStr);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  } catch (_) {}
                },
                icon: const Icon(Icons.launch_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Open Website Button',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openScholarshipApplicationFormModal(Map<String, dynamic> sch) {
    final String mode = sch['applicationMode'] ??
        (sch['portalUrl'] != null &&
                (sch['portalUrl'].toString().contains('mahadbt') ||
                    sch['portalUrl'].toString().contains('scholarships.gov') ||
                    sch['portalUrl'].toString().contains('tatatrusts'))
            ? 'EXTERNAL_WEBSITE'
            : 'IN_APP');

    if (mode == 'EXTERNAL_WEBSITE') {
      _handleExternalWebsiteScholarship(sch);
      return;
    }

    final existingApp = _myApplications.firstWhere(
      (a) => a['title'] == sch['title'] || a['id'] == sch['id'],
      orElse: () => {},
    );

    if (existingApp.isNotEmpty &&
        existingApp['application_status'] != 'Draft' &&
        existingApp['application_status'] != 'In Progress') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: primaryGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                'Already Submitted',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'You have already submitted an application for "${sch['title']}". Status: ${existingApp['application_status']}. Form is locked for editing.',
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(2);
                setState(() {
                  _expandedAppId = existingApp['id'] as String?;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Go to Tracker', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScholarshipApplyStepperScreen(
          scholarshipName: (sch['title'] ?? sch['scholarship_name'] ?? 'MSBTE Merit Scholarship') as String,
          scholarshipAmount: (sch['amount'] ?? '₹25,000') as String,
          studentId: widget.studentId,
          studentName: widget.userName,
          initialDraft: existingApp.isNotEmpty ? existingApp : null,
          isEditable: true,
          applicationStatus: existingApp['application_status'] ?? 'Draft',
          onDraftSaved: (draftData) {
            setState(() {
              final idx = _myApplications.indexWhere((a) => a['title'] == sch['title']);
              if (idx >= 0) {
                _myApplications[idx]['application_status'] = 'Draft';
                _myApplications[idx]['formData'] = draftData['formData'];
              } else {
                _myApplications.insert(0, {
                  'id': 'DRAFT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  'title': sch['title'],
                  'provider': sch['provider'],
                  'amount': sch['amount'],
                  'appliedDate': DateTime.now().toIso8601String(),
                  'application_status': 'Draft',
                  'statusColor': const Color(0xFF6B7280),
                  'remarks': 'Draft application saved. Ready to resume.',
                  'formData': draftData['formData'],
                });
              }
            });
          },
          onSubmitted: (subData) {
            setState(() {
              final idx = _myApplications.indexWhere((a) => a['title'] == sch['title']);
              if (idx >= 0) {
                _myApplications[idx]['application_status'] = 'Submitted';
                _myApplications[idx]['formData'] = subData['formData'];
              } else {
                _myApplications.insert(0, {
                  'id': 'SCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  'title': sch['title'],
                  'provider': sch['provider'],
                  'amount': sch['amount'],
                  'appliedDate': DateTime.now().toIso8601String(),
                  'application_status': 'Submitted',
                  'statusColor': const Color(0xFF2563EB),
                  'remarks': 'Application submitted directly inside app.',
                  'formData': subData['formData'],
                });
              }
            });
          },
        ),
      ),
    );
  }

  void _openSubmittedFormDetailsModal(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(22),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Submitted Application Record',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryGreen.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          app['id'] as String,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(app['title'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(app['provider'] as String, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Applicant Credentials', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: primaryGreen)),
                        const Divider(height: 14),
                        _buildReceiptDetailRow('Applicant Name:', (app['applicantName'] as String?) ?? widget.userName),
                        _buildReceiptDetailRow('Student ID / PRN:', widget.studentId),
                        _buildReceiptDetailRow('Academic Program:', (app['course'] as String?) ?? 'Degree 3rd Year'),
                        _buildReceiptDetailRow('Submitted CGPA:', '${(app['cgpa'] as String?) ?? '8.5'} / 10'),
                        _buildReceiptDetailRow('Annual Family Income:', '₹${(app['annualIncome'] as String?) ?? '3,50,000'}'),
                        _buildReceiptDetailRow('Category:', (app['category'] as String?) ?? 'OPEN / EWS'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statement of Purpose (SOP)', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: primaryGreen)),
                        const SizedBox(height: 6),
                        Text(
                          (app['sop'] as String?) ?? 'Submitted for undergraduate tuition support under MahaDBT guidelines.',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: emeraldAccent.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_special_rounded, color: primaryGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Digital Vault Attached Documents',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen),
                              ),
                              Text(
                                '${app['attachedDocsCount'] ?? 5} Verified Documents attached (Marksheet, Income Proof, Aadhaar, Domicile, Bank Passbook)',
                                style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openApplicationSlipModal(app);
                      },
                      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                      label: Text('View & Download Receipt Slip', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openApplicationSlipModal(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(22),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Official Acknowledgement',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MAHARASHTRA STATE SCHOLARSHIP PORTAL',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app['title'] as String,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        app['provider'] as String,
                        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                _buildReceiptDetailRow('Application Reference ID:', app['id'] as String),
                _buildReceiptDetailRow('Applicant Name:', (app['applicantName'] as String?) ?? widget.userName),
                _buildReceiptDetailRow('Student PRN:', widget.studentId),
                _buildReceiptDetailRow('Submission Date:', app['appliedDate'] as String),
                _buildReceiptDetailRow('Scholarship Grant:', app['amount'] as String),
                _buildReceiptDetailRow('Disbursal Target:', app['bankAccount'] as String),
                _buildReceiptDetailRow('Current Status:', app['status'] as String),

                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 50, color: Colors.grey[800]),
                      const SizedBox(height: 4),
                      Text(
                        'VERIFIED BY MAHADBT & MSBTE DIGITAL SEAL',
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Official Confirmation Slip downloaded to device storage!'),
                          backgroundColor: primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Download Official Slip PDF',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _openSmartEligibilityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: goldAccent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Smart Eligibility Checker',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                      'Course Program',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedCourse,
                      isExpanded: true,
                      items:
                          [
                                'Degree (B.Tech / B.E.)',
                                'Diploma Engg',
                                'M.Tech / Postgrad',
                                'B.Sc / Computer Science',
                              ]
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedCourse = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Department',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedDept,
                      isExpanded: true,
                      items:
                          [
                                'Computer Science & Engineering',
                                'Information Technology',
                                'Mechanical Engg',
                                'Civil Engg',
                                'Electrical Engg',
                              ]
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedDept = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Academic Year',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(
                                y,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _selectedYear = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CGPA / Marks: ${_cgpaInput.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _cgpaInput,
                      min: 5.0,
                      max: 10.0,
                      divisions: 50,
                      activeColor: primaryGreen,
                      onChanged: (val) {
                        setDialogState(() => _cgpaInput = val);
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family Income: ₹${_incomeInput.toStringAsFixed(1)} Lakhs',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _incomeInput,
                      min: 0.5,
                      max: 12.0,
                      divisions: 115,
                      activeColor: primaryGreen,
                      onChanged: (val) {
                        setDialogState(() => _incomeInput = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _eligibilityChecked = true;
                      _isEligibleResult =
                          _cgpaInput >= 7.5 && _incomeInput <= 8.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isEligibleResult
                              ? 'Eligible ✓ You match 5 State & MSBTE Scholarships!'
                              : 'Income/CGPA criteria restricts 2 schemes, but 3 remaining schemes match!',
                        ),
                        backgroundColor: _isEligibleResult
                            ? primaryGreen
                            : const Color(0xFFD97706),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                  ),
                  child: Text(
                    'Check Results',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openDocumentVaultModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Digital Document Vault',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: primaryGreen,
                          size: 28,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Document auto-uploading to Vault... Verified ✓',
                              ),
                              backgroundColor: primaryGreen,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Store and re-use verified documents across multiple applications',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _documentVault.length,
                    itemBuilder: (context, index) {
                      final doc = _documentVault[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryGreen.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                doc['icon'] as IconData,
                                color: primaryGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${doc['category']} • ${doc['fileSize']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'VERIFIED ✓',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openNotificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Deadline Reminder Center',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Never miss a scholarship closing deadline',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    activeTrackColor: primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Automated Push Notifications & Alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Receive alerts 7 days & 2 days before deadline closing',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    value: _remindersEnabled,
                    onChanged: (val) {
                      setModalState(() => _remindersEnabled = val);
                      setState(() => _remindersEnabled = val);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  Text(
                    'Closing Deadlines List',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableScholarships.length,
                      itemBuilder: (context, index) {
                        final sch = _availableScholarships[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sch['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Closing Date: ${sch['deadline']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${sch['daysLeft']} Days Left',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openTransferToBankModal() {
    int transferAmount = 25000;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        color: primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Transfer to Bank Account',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Withdraw scholarship credits to your linked bank account',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HDFC Bank •••• 4892',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'IFSC: HDFC0001294 • ${widget.userName}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'VERIFIED ✓',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Select Amount to Transfer',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children:
                        [5000, 10000, 25000].map((amt) {
                          final isSel = transferAmount == amt;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text('₹$amt'),
                              selected: isSel,
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() => transferAmount = amt);
                                }
                              },
                              selectedColor: primaryGreen,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSel
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _walletTransactions.insert(0, {
                            'id':
                                'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}',
                            'title': 'Bank Withdrawal to HDFC',
                            'scholarship': 'Direct Payout to Bank Account',
                            'amount':
                                '₹${transferAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            'date': 'Just Now',
                            'status': 'Credited to HDFC Bank (•••• 4892)',
                            'isCredit': false,
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully transferred ₹$transferAmount to HDFC Bank (•••• 4892) ✓',
                            ),
                            backgroundColor: primaryGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Confirm Bank Transfer',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openPayFeeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    color: primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Direct Fee Subsidization',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Apply available scholarship balance directly to your college tuition fee',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goldAccent),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gross College Fee:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₹75,000',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scholarship Credit Applied:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '- ₹${_totalReceivedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Payable Fee:',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_netFeeRemaining.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Scholarship Direct Credit of ₹25,000 applied to Autumn Semester Fee! Receipt Generated ✓',
                        ),
                        backgroundColor: primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Apply Credit & Pay Balance via UPI',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReceiptModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // NO OVERFLOW HEADER ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Disbursal Slip & Receipt',
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryGreen.withAlpha(40)),
                    ),
                    child: Text(
                      'OFFICIAL VOUCHER ✓',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
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
                                      'MAHADBT / MSBTE DTE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    Text(
                                      'Govt. Financial Aid Disbursal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: primaryGreen,
                                  size: 28,
                                ),
                              ],
                            ),
                            const Divider(height: 22),

                            _buildReceiptRow('Beneficiary Name', widget.userName),
                            _buildReceiptRow(
                              'Campus Student ID',
                              widget.studentId,
                            ),
                            _buildReceiptRow(
                              'Scholarship Scheme',
                              'MSBTE Merit Scholarship 2026',
                            ),
                            _buildReceiptRow(
                              'Disbursed Amount',
                              '₹25,000 (INR)',
                            ),
                            _buildReceiptRow(
                              'Payment UTR / Ref',
                              'UTR98421092482',
                            ),
                            _buildReceiptRow(
                              'Disbursal Bank',
                              'HDFC Bank (•••• 4892)',
                            ),
                            _buildReceiptRow(
                              'Date & Timestamp',
                              '01 Sep 2026, 09:45 AM',
                            ),
                            _buildReceiptRow(
                              'Fee Offset Status',
                              'Direct Tuition Subsidization Applied',
                            ),

                            const SizedBox(height: 14),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 36,
                                      color: primaryGreen,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Scan to Verify Slip',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Cryptographically Signed',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            color: AppColors.textSecondary,
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
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfReceiptViewerScreen(
                                  userName: widget.userName,
                                  studentId: widget.studentId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            'Download PDF Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
      },
    );
  }


  void _openTransactionDetailsModal(Map<String, dynamic> txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Transaction Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Disbursal Audit Record',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(
                      'Transaction Title',
                      txn['title'] as String,
                    ),
                    _buildReceiptRow('Transaction ID', txn['id'] as String),
                    _buildReceiptRow(
                      'Scholarship Scheme',
                      (txn['scholarship'] ?? 'Merit Scholarship') as String,
                    ),
                    _buildReceiptRow('Amount', txn['amount'] as String),
                    _buildReceiptRow('Date & Time', txn['date'] as String),
                    _buildReceiptRow(
                      'Disbursal Status',
                      txn['status'] as String,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfReceiptViewerScreen(
                          userName: widget.userName,
                          studentId: widget.studentId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: Text(
                    'View Full Disbursal Slip',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              val,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FULL SCREEN PDF RECEIPT VIEWER SCREEN & INTERACTIVE MOCK SHARE/PRINT FLOWS
// ============================================================================

class PdfReceiptViewerScreen extends StatefulWidget {
  final String userName;
  final String studentId;

  const PdfReceiptViewerScreen({
    super.key,
    this.userName = 'Hitija Mhatre',
    this.studentId = 'CMP-2026-8910',
  });

  @override
  State<PdfReceiptViewerScreen> createState() => _PdfReceiptViewerScreenState();
}

class _PdfReceiptViewerScreenState extends State<PdfReceiptViewerScreen> {
  double _zoomLevel = 1.0;
  static const Color primaryGreen = Color(0xFF0D5C3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Receipt Viewer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Disbursal_Receipt_MSBTE_2026.pdf (1.2 MB)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Print PDF',
            icon: const Icon(Icons.print_rounded, color: Colors.white),
            onPressed: () => _openPrintDialog(context),
          ),
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => _openShareSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TOP SUCCESS BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.green[50],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF Downloaded & Saved Successfully ✓',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        Text(
                          'File: Disbursal_Receipt_MSBTE_2026.pdf (1.2 MB) • Saved to Downloads',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PDF VIEWER TOOLBAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF334155),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Disbursal_Receipt_MSBTE.pdf',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white70, size: 18),
                        onPressed: () {
                          if (_zoomLevel > 0.8) setState(() => _zoomLevel -= 0.1);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(_zoomLevel * 100).toInt()}%',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 18),
                        onPressed: () {
                          if (_zoomLevel < 1.4) setState(() => _zoomLevel += 0.1);
                        },
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Page 1 of 1',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CANVAS AREA WITH CERTIFICATE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Transform.scale(
                  scale: _zoomLevel,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STATE GOVT HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GOVT. OF MAHARASHTRA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    'Directorate of Technical Education',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  Text(
                                    'MAHADBT Financial Aid Portal 2026',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryGreen.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: primaryGreen,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 22, thickness: 1.2),

                        // REF & DATE
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ref: MAHADBT/2026/FIN/892014',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Date: 01 Sep 2026',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // BENEFICIARY RECORD
                        Text(
                          'STUDENT & SCHEME AUDIT RECORD',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildViewerRow('Beneficiary Name', widget.userName),
                        _buildViewerRow('Campus Student ID', widget.studentId),
                        _buildViewerRow('Scholarship Scheme', 'MSBTE Merit Scholarship'),
                        _buildViewerRow('Academic Year', '2026 - 2027 (Autumn)'),

                        const Divider(height: 22),

                        // DISBURSED LEDGER
                        Text(
                          'DISBURSED LEDGER BREAKDOWN',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildViewerRow('State Merit Support', '₹20,000.00'),
                        _buildViewerRow('Book & Equipment Grant', '₹3,000.00'),
                        _buildViewerRow('Special Academic Subsidy', '₹2,000.00'),
                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryGreen.withAlpha(60)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL CREDITED:',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                              Text(
                                '₹25,000 (INR)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 22),

                        // BANKING DETAILS
                        _buildViewerRow('Bank Account', 'HDFC Bank (•••• 4892)'),
                        _buildViewerRow('Payment UTR', 'UTR98421092482'),
                        _buildViewerRow('Disbursal Mode', 'Direct Benefit Transfer (DBT)'),
                        _buildViewerRow('Audit Status', 'VERIFIED & CREDITED ✓'),

                        const SizedBox(height: 16),

                        // DIGITAL QR SEAL
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 44,
                                color: primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Digitally Signed Voucher',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Financial Disbursal Officer, Govt. of Maharashtra',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Hash: e3b0c44298fc1c149afbf4c8996fb924',
                                      style: GoogleFonts.poppins(
                                        fontSize: 8,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Center(
                          child: Text(
                            '*** End of Official PDF Disbursal Voucher ***',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildViewerRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              val,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SHARE SELECTION SHEET
  // --------------------------------------------------------------------------
  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.share_rounded, color: primaryGreen, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Share Receipt PDF',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Disbursal_Receipt_MSBTE_2026.pdf (1.2 MB)',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),

              // TARGET APPS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareAppTile(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openWhatsAppShareModal(context);
                    },
                  ),
                  _buildShareAppTile(
                    icon: Icons.email_rounded,
                    label: 'Gmail',
                    color: const Color(0xFFEA4335),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGmailComposeModal(context);
                    },
                  ),
                  _buildShareAppTile(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Drive',
                    color: const Color(0xFF4285F4),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGoogleDriveModal(context);
                    },
                  ),
                  _buildShareAppTile(
                    icon: Icons.print_rounded,
                    label: 'Print',
                    color: const Color(0xFF334155),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openPrintDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Text(
                'Quick Recipients',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.person_rounded, size: 16, color: primaryGreen),
                      label: Text(
                        'Parent / Guardian (WhatsApp)',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openWhatsAppShareModal(context, selectedRecipient: 'Parent / Guardian (+91 98201 44892)');
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.account_balance_rounded, size: 16, color: primaryGreen),
                      label: Text(
                        'College Accounts (Email)',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openGmailComposeModal(context, recipientEmail: 'college.accounts@engg.edu.in');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareAppTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // REAL WHATSAPP SHARE FLOW MODAL
  // --------------------------------------------------------------------------
  void _openWhatsAppShareModal(BuildContext context, {String? selectedRecipient}) {
    String recipient = selectedRecipient ?? 'Parent / Guardian (+91 98201 44892)';
    final String defaultRealCaption = '''🎓 GOVT. OF MAHARASHTRA • MAHADBT
Official Scholarship Disbursal Voucher

👤 Student Name: ${widget.userName}
🆔 Student ID: ${widget.studentId}
📜 Scheme: MSBTE Merit Scholarship 2026
💰 Disbursed Amount: ₹25,000 (INR)
🏦 Bank Account: HDFC Bank (•••• 4892)
🧾 Payment UTR: UTR98421092482
📅 Disbursal Date: 01 Sep 2026

✓ Verified by Directorate of Technical Education, Govt. of Maharashtra''';

    final TextEditingController msgController = TextEditingController(text: defaultRealCaption);
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5DDD5), // Authentic WhatsApp Chat wallpaper bg
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // WHATSAPP HEADER BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF075E54), // WhatsApp Dark Teal
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send to WhatsApp',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'WhatsApp Business • Direct Media Share',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),

                    if (isSending) ...[
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF25D366)),
                            const SizedBox(height: 16),
                            Text(
                              'Sending PDF via WhatsApp...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // RECIPIENT SELECTOR DROPDOWN
                            Text(
                              'Select WhatsApp Contact / Group',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: recipient,
                                  isExpanded: true,
                                  items: [
                                    'Parent / Guardian (+91 98201 44892)',
                                    'College Registrar Office',
                                    'Hitija Mhatre (Me / Notes)',
                                    '3rd Year Engg Batch Group (24 members)',
                                  ]
                                      .map(
                                        (item) => DropdownMenuItem(
                                          value: item,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.account_circle, color: Color(0xFF075E54), size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                item,
                                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => recipient = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // WHATSAPP ATTACHMENT CARD PREVIEW
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Disbursal_Receipt_MSBTE_2026.pdf',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '1.2 MB • PDF Document • Official Voucher',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9.5,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // MESSAGE INPUT
                            Text(
                              'Add Message Caption',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: msgController,
                              maxLines: 3,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Add a message caption...',
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // SEND TO WHATSAPP BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setModalState(() => isSending = true);
                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    if (modalCtx.mounted) {
                                      Navigator.pop(modalCtx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WhatsAppChatScreen(
                                            recipient: recipient,
                                            userName: widget.userName,
                                            studentId: widget.studentId,
                                            captionText: msgController.text,
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                                icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                label: Text(
                                  'Send to WhatsApp',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // --------------------------------------------------------------------------
  // REAL GMAIL COMPOSE EMAIL FLOW MODAL
  // --------------------------------------------------------------------------
  void _openGmailComposeModal(BuildContext context, {String? recipientEmail}) {
    final TextEditingController toController = TextEditingController(
      text: recipientEmail ?? 'college.accounts@msbte.edu.in',
    );
    final TextEditingController subjectController = TextEditingController(
      text: 'Scholarship Disbursal Receipt - Hitija Mhatre (CMP-2026-8910)',
    );
    final TextEditingController bodyController = TextEditingController(
      text: '''Respected Sir/Madam,

Please find attached the official PDF disbursal receipt for my MSBTE Merit Scholarship.

--- DISBURSAL AUDIT DETAILS ---
• Student Name: ${widget.userName}
• Campus Student ID: ${widget.studentId}
• Scholarship Scheme: MSBTE Merit Scholarship 2026
• Disbursed Amount: ₹25,000 (INR)
• Bank Account: HDFC Bank (•••• 4892)
• Transaction UTR: UTR98421092482
• Disbursal Timestamp: 01 Sep 2026, 09:45 AM
• Audit Verification: Directorate of Technical Education, Govt. of Maharashtra

Thank you,
${widget.userName}''',
    );
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // GMAIL RED HEADER BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA4335), // Gmail Red
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mail_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Compose Gmail',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),

                    if (isSending) ...[
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: Color(0xFFEA4335)),
                            const SizedBox(height: 16),
                            Text(
                              'Sending Email with PDF attachment...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: TextEditingController(text: 'hitija.mhatre@student.edu.in'),
                              enabled: false,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'From',
                                prefixIcon: Icon(Icons.person, size: 18),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: toController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'To',
                                prefixIcon: Icon(Icons.alternate_email, size: 18),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: subjectController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                prefixIcon: Icon(Icons.subject, size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ATTACHMENT CHIP BOX
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.withAlpha(60)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file_rounded, color: Color(0xFFEA4335), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Disbursal_Receipt_MSBTE_2026.pdf (1.2 MB)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFEA4335),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFFEA4335), size: 18),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: bodyController,
                              maxLines: 4,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Compose email...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setModalState(() => isSending = true);
                                  Future.delayed(const Duration(milliseconds: 1200), () {
                                    if (modalCtx.mounted) {
                                      Navigator.pop(modalCtx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Email dispatched via Gmail to ${toController.text} ✓'),
                                          backgroundColor: const Color(0xFFEA4335),
                                        ),
                                      );
                                    }
                                  });
                                },
                                icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                label: Text(
                                  'Send Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8), // Gmail Blue Button
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // --------------------------------------------------------------------------
  // REAL GOOGLE DRIVE UPLOAD FLOW MODAL
  // --------------------------------------------------------------------------
  void _openGoogleDriveModal(BuildContext context) {
    String selectedFolder = '📁 /My Drive/Scholarships 2026/';
    bool isUploading = false;
    double progress = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
              ),
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: Color(0xFF4285F4), size: 26),
                      const SizedBox(width: 10),
                      Text(
                        'Upload to Google Drive',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isUploading) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            color: const Color(0xFF4285F4),
                            backgroundColor: Colors.grey[200],
                            minHeight: 8,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Uploading Disbursal_Receipt_MSBTE_2026.pdf (${(progress * 100).toInt()}%)...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildDriveField('Account', 'hitija.mhatre@student.edu.in'),
                    const SizedBox(height: 10),
                    _buildDriveField('File Name', 'Disbursal_Receipt_MSBTE_2026.pdf'),
                    const SizedBox(height: 10),

                    Text(
                      'Destination Folder',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedFolder,
                          isExpanded: true,
                          items: [
                            '📁 /My Drive/Scholarships 2026/',
                            '📁 /My Drive/Campus Financial Records/',
                            '📁 /My Drive/Personal Receipts/',
                          ]
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(
                                    f,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedFolder = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setModalState(() {
                            isUploading = true;
                            progress = 0.2;
                          });
                          Future.delayed(const Duration(milliseconds: 400), () {
                            setModalState(() => progress = 0.6);
                          });
                          Future.delayed(const Duration(milliseconds: 800), () {
                            setModalState(() => progress = 1.0);
                          });
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (modalCtx.mounted) {
                              Navigator.pop(modalCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Disbursal Receipt uploaded to Google Drive ($selectedFolder) ✓'),
                                  backgroundColor: const Color(0xFF4285F4),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.cloud_upload_rounded, size: 18, color: Colors.white),
                        label: Text(
                          'Upload to Drive',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildDriveField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // REAL SYSTEM PRINT SPOOLER FLOW DIALOG
  // --------------------------------------------------------------------------
  void _openPrintDialog(BuildContext context) {
    String selectedPrinter = 'HP LaserJet Pro (Campus Library Wi-Fi)';
    int copies = 1;
    bool isColor = true;
    bool isPrinting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
              ),
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.print_rounded, color: primaryGreen, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Print PDF Receipt',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Campus Wireless Printer Spooler & Settings',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),

                  if (isPrinting) ...[
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: primaryGreen),
                          const SizedBox(height: 16),
                          Text(
                            'Sending job to $selectedPrinter...',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Destination Printer',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPrinter,
                          isExpanded: true,
                          items: [
                            'HP LaserJet Pro (Campus Library Wi-Fi)',
                            'Canon PIXMA (Admin Block 3)',
                            'Epson EcoTank (Department Office)',
                            'Save as PDF (Local Storage)',
                          ]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedPrinter = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Copies', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: copies > 1 ? () => setModalState(() => copies--) : null,
                                      icon: const Icon(Icons.remove_circle_outline),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Text(
                                      '$copies',
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      onPressed: () => setModalState(() => copies++),
                                      icon: const Icon(Icons.add_circle_outline),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Color Mode', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isColor ? 'Color' : 'Monochrome',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isColor ? primaryGreen : Colors.grey[700],
                                      ),
                                    ),
                                    Switch(
                                      value: isColor,
                                      activeTrackColor: primaryGreen,
                                      onChanged: (val) => setModalState(() => isColor = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setModalState(() => isPrinting = true);
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (modalCtx.mounted) {
                              Navigator.pop(modalCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Print job ($copies ${copies > 1 ? 'copies' : 'copy'}) sent to "$selectedPrinter" ✓'),
                                  backgroundColor: primaryGreen,
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: Text(
                          'Send to Printer',
                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}

// ============================================================================
// REAL WHATSAPP CHAT PREVIEW SCREEN WITH REAL PDF & RECEIPT DATA
// ============================================================================

class WhatsAppChatScreen extends StatefulWidget {
  final String recipient;
  final String userName;
  final String studentId;
  final String captionText;

  const WhatsAppChatScreen({
    super.key,
    required this.recipient,
    required this.userName,
    required this.studentId,
    required this.captionText,
  });

  @override
  State<WhatsAppChatScreen> createState() => _WhatsAppChatScreenState();
}

class _WhatsAppChatScreenState extends State<WhatsAppChatScreen> {
  final TextEditingController _newMsgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // Authentic WhatsApp Chat Wallpaper
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp Dark Teal
        leadingWidth: 70,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.recipient.startsWith('Parent') ? 'P' : 'C',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipient,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'online',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: const Color(0xFF25D366),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
          // TODAY DATE STAMP
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'TODAY',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // INCOMING REQUEST MESSAGE FROM RECIPIENT
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 60, top: 4, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please share your official MSBTE scholarship disbursal receipt PDF.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '10:14 AM',
                      style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // OUTGOING SENT WHATSAPP MESSAGE BUBBLE WITH REAL RECEIPT DATA & PDF
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(left: 45, right: 12, top: 4, bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6), // WhatsApp Sent Bubble Light Green
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF ATTACHMENT HEADER INSIDE BUBBLE
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFE9BA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Disbursal_Receipt_MSBTE_2026.pdf',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '1.2 MB • PDF • Official Voucher',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // REAL RECEIPT DATA CAPTION
                  Text(
                    'MSBTE Scholarship Sanction Receipt & Fee Disbursal Certificate',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      Text(
                        '10:15 AM',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all_rounded, // Double Blue Tick
                        size: 16,
                        color: Color(0xFF34B7F1),
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

          // WHATSAPP INPUT BAR AT BOTTOM
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFFF0F0F0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.grey[600], size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _newMsgController,
                            style: GoogleFonts.poppins(fontSize: 12.5),
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.attach_file_rounded, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Icon(Icons.camera_alt_rounded, color: Colors.grey[600], size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF075E54),
                  child: Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
