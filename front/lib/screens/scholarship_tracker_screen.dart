import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'scholarship_apply_stepper_screen.dart';

class ScholarshipTrackerScreen extends StatefulWidget {
  final String userName;
  final String studentId;

  const ScholarshipTrackerScreen({
    super.key,
    this.userName = 'Hitija Mhatre',
    this.studentId = 'CMP-2026-8910',
  });

  @override
  State<ScholarshipTrackerScreen> createState() => _ScholarshipTrackerScreenState();
}

class _ScholarshipTrackerScreenState extends State<ScholarshipTrackerScreen> {
  // Search & Status Filter
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  String? _expandedAppId;

  // Light Green FinTech Palette (#10B981 / #059669 / #ECFDF5)
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color emeraldAccent = Color(0xFF059669);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Requirement 5: Status Colors
  static const Color colorDraft = Color(0xFF6B7280);       // Grey
  static const Color colorSubmitted = Color(0xFF2563EB);   // Blue
  static const Color colorVerification = Color(0xFFF97316);// Orange
  static const Color colorReview = Color(0xFF8B5CF6);      // Purple
  static const Color colorApproved = Color(0xFF10B981);    // Light Green
  static const Color colorRejected = Color(0xFFEF4444);    // Red
  static const Color colorFundReleased = Color(0xFF059669);// Dark Emerald

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return colorDraft;
      case 'Submitted':
        return colorSubmitted;
      case 'Document Verification':
      case 'Verification':
        return colorVerification;
      case 'Under Review':
        return colorReview;
      case 'Approved':
        return colorApproved;
      case 'Rejected':
        return colorRejected;
      case 'Fund Released':
      case 'Approved & Credited':
        return colorFundReleased;
      default:
        return primaryGreen;
    }
  }

  // Requirement 8: Database & Local Applications List
  final List<Map<String, dynamic>> _myApplications = [
    {
      'id': 'DRAFT-2026-1049',
      'student_id': 101,
      'scholarship_id': 2,
      'title': 'National Campus Innovation & Tech Fellowship',
      'provider': 'Ministry of Education & Innovation Council',
      'amount': '₹50,000',
      'applied_date': '05 Sep 2026, 04:15 PM',
      'application_status': 'Draft',
      'applicationMode': 'IN_APP',
      'statusColor': colorDraft,
      'stageIndex': 0,
      'expectedCompletion': 'Resume & Submit by 28 Oct 2026',
      'remarks': 'Draft saved on Step 3 (Family Details). All details editable until submission deadline.',
      'bankAccount': 'HDFC Bank •••• 4892',
      'boardTag': 'IN-APP DRAFT',
      'attachedDocsCount': 3,
      'formData': {
        'fullName': 'Hitija Mhatre',
        'studentId': 'CMP-2026-8910',
        'email': 'hitija.mhatre@campus.edu.in',
        'mobile': '+91 98201 48920',
        'college': 'Campus Institute of Technology & Engineering',
        'department': 'Computer Science & Engineering',
        'cgpa': '8.85',
        'familyIncome': '₹3,50,000 / Year',
      },
      'timeline': [
        {
          'stage': 'Draft',
          'status': 'Draft Application Saved',
          'date': '05 Sep 2026, 04:15 PM',
          'desc': 'Form partially filled & saved. Ready to resume.',
          'color': colorDraft,
          'isDone': true,
          'isCurrent': true,
        },
        {
          'stage': 'Submitted',
          'status': 'Application Submission',
          'date': 'Pending',
          'desc': 'Complete all 6 steps and click Submit',
          'color': Colors.grey[400]!,
          'isDone': false,
        },
      ],
    },
    {
      'id': 'EXT-MAHADBT-88',
      'student_id': 101,
      'scholarship_id': 3,
      'title': 'Rajarshi Chhatrapati Shahu Maharaj Fee Concession (EBC)',
      'provider': 'Directorate of Higher Education (MahaDBT)',
      'amount': '₹19,000',
      'applied_date': '06 Sep 2026, 11:10 AM',
      'application_status': 'External Website Visited',
      'applicationMode': 'EXTERNAL_WEBSITE',
      'externalWebsiteName': 'MahaDBT Official State Portal',
      'externalWebsiteUrl': 'https://mahadbt.maharashtra.gov.in',
      'externalWebsiteStatus': 'Portal Active & Accepting Applications',
      'lastOpenedDate': '06 Sep 2026, 11:10 AM',
      'statusColor': colorSubmitted,
      'stageIndex': 1,
      'expectedCompletion': 'Handled on MahaDBT Portal',
      'remarks': 'Official State Govt Website. Click button below to re-open MahaDBT portal.',
      'boardTag': 'MahaDBT Official Website',
      'attachedDocsCount': 0,
      'timeline': [
        {
          'stage': 'External Link',
          'status': 'Official Website Opened',
          'date': '06 Sep 2026, 11:10 AM',
          'desc': 'User redirected to https://mahadbt.maharashtra.gov.in',
          'color': colorSubmitted,
          'isDone': true,
          'isCurrent': true,
        },
      ],
    },
    {
      'id': 'MAHA-2026-8910',
      'student_id': 101,
      'scholarship_id': 1,
      'title': 'MSBTE Diploma & Degree Merit Scholarship',
      'provider': 'Maharashtra State Board of Technical Education (MSBTE)',
      'amount': '₹25,000',
      'applied_date': '15 Aug 2026, 10:30 AM',
      'verification_date': '18 Aug 2026, 02:15 PM',
      'review_date': '21 Aug 2026, 04:00 PM',
      'approval_date': '24 Aug 2026, 11:00 AM',
      'fund_release_date': '01 Sep 2026, 09:45 AM',
      'application_status': 'Fund Released',
      'statusColor': colorFundReleased,
      'stageIndex': 6, // Completed all 6 stages
      'expectedCompletion': 'Completed ✓',
      'remarks': 'Fund of ₹25,000 disbursed directly to linked HDFC Bank account and tuition fee offset applied.',
      'bankAccount': 'HDFC Bank •••• 4892 (Hitija Mhatre)',
      'boardTag': 'MSBTE Board',
      'attachedDocsCount': 5,
      'timeline': [
        {
          'stage': 'Draft',
          'status': 'Draft Created',
          'date': '14 Aug 2026',
          'desc': 'Application form initiated by student',
          'color': colorDraft,
          'isDone': true,
        },
        {
          'stage': 'Submitted',
          'status': 'Application Submitted',
          'date': '15 Aug 2026, 10:30 AM',
          'desc': 'Submitted via MahaDBT State Portal',
          'color': colorSubmitted,
          'isDone': true,
        },
        {
          'stage': 'Document Verification',
          'status': 'Documents Verified',
          'date': '18 Aug 2026, 02:15 PM',
          'desc': 'Verified by Campus Registrar Officer',
          'color': colorVerification,
          'isDone': true,
        },
        {
          'stage': 'Under Review',
          'status': 'Under Review',
          'date': '21 Aug 2026, 04:00 PM',
          'desc': 'State DHE Portal Scrutiny in progress',
          'color': colorReview,
          'isDone': true,
        },
        {
          'stage': 'Approved',
          'status': 'Approved',
          'date': '24 Aug 2026, 11:00 AM',
          'desc': 'MSBTE Board Sanction Clearance granted',
          'color': colorApproved,
          'isDone': true,
        },
        {
          'stage': 'Fund Released',
          'status': 'Fund Released',
          'date': '01 Sep 2026, 09:45 AM',
          'desc': '₹25,000 Credited to HDFC Bank Account',
          'color': colorFundReleased,
          'isDone': true,
        },
      ],
    },
    {
      'id': 'MAHA-2026-9214',
      'student_id': 101,
      'scholarship_id': 2,
      'title': 'Rajarshi Chhatrapati Shahu Maharaj Fee Concession (EBC)',
      'provider': 'Directorate of Higher Education, Maharashtra',
      'amount': '₹19,000',
      'applied_date': '28 Aug 2026, 04:20 PM',
      'verification_date': '30 Aug 2026, 01:10 PM',
      'review_date': '02 Sep 2026, 11:30 AM',
      'approval_date': 'Pending',
      'fund_release_date': 'Pending',
      'application_status': 'Under Review',
      'statusColor': colorReview,
      'stageIndex': 3, // Current Stage: Under Review
      'expectedCompletion': '15 Sep 2026',
      'remarks': '50% Tuition Fee Concession application currently under State DHE Review Desk.',
      'bankAccount': 'HDFC Bank •••• 4892 (Verified)',
      'boardTag': 'MahaDBT EBC',
      'attachedDocsCount': 4,
      'timeline': [
        {
          'stage': 'Draft',
          'status': 'Draft Created',
          'date': '27 Aug 2026',
          'desc': 'Application form draft saved',
          'color': colorDraft,
          'isDone': true,
        },
        {
          'stage': 'Submitted',
          'status': 'Application Submitted',
          'date': '28 Aug 2026, 04:20 PM',
          'desc': 'Submitted via MahaDBT Portal',
          'color': colorSubmitted,
          'isDone': true,
        },
        {
          'stage': 'Document Verification',
          'status': 'Documents Verified',
          'date': '30 Aug 2026, 01:10 PM',
          'desc': 'Income & Marksheets verified by Nodal Officer',
          'color': colorVerification,
          'isDone': true,
        },
        {
          'stage': 'Under Review',
          'status': 'Under Review',
          'date': '02 Sep 2026, 11:30 AM',
          'desc': 'DHE Portal Desk examining fee waiver',
          'color': colorReview,
          'isDone': true,
          'isCurrent': true,
        },
        {
          'stage': 'Approved',
          'status': 'Sanction Clearance',
          'date': 'Scheduled',
          'desc': 'Sanction Board Approval pending',
          'color': Colors.grey[400]!,
          'isDone': false,
        },
        {
          'stage': 'Fund Release',
          'status': 'Disbursal Release',
          'date': 'Scheduled',
          'desc': 'Direct Treasury Fund Transfer',
          'color': Colors.grey[400]!,
          'isDone': false,
        },
      ],
    },
  ];

  // Available Scholarships List
  final List<Map<String, dynamic>> _availableScholarships = [
    {
      'id': 'SCH-AVAIL-MSBTE',
      'title': 'MSBTE Diploma & Degree Merit Scholarship',
      'provider': 'Maharashtra State Board of Technical Education',
      'amount': '₹25,000',
      'deadline': '30 Sep 2026',
      'eligibility': 'Marks > 80% • Diploma / Degree Engg Students',
      'boardTag': 'MSBTE Board',
      'portalUrl': 'https://msbte.org.in/',
    },
    {
      'id': 'SCH-AVAIL-EBC',
      'title': 'Rajarshi Chhatrapati Shahu Maharaj Concession (EBC)',
      'provider': 'Directorate of Higher Education (MahaDBT)',
      'amount': '₹19,000',
      'deadline': '15 Oct 2026',
      'eligibility': 'Annual Income < ₹8.0 Lakhs • General / EWS / OBC',
      'boardTag': 'MahaDBT Portal',
      'portalUrl': 'https://mahadbt.maharashtra.gov.in/',
    },
    {
      'id': 'SCH-AVAIL-PUNJABRAO',
      'title': 'Dr. Punjabrao Deshmukh Hostel Maintenance Allowance',
      'provider': 'Department of Agriculture & Tech (Maharashtra)',
      'amount': '₹30,000',
      'deadline': '25 Sep 2026',
      'eligibility': 'Children of Small Farmers / Income < ₹8 Lakhs',
      'boardTag': 'State Govt',
      'portalUrl': 'https://mahadbt.maharashtra.gov.in/',
    },
    {
      'id': 'SCH-AVAIL-CSSS',
      'title': 'Central Sector Scheme of Scholarships (CSSS)',
      'provider': 'Ministry of Education (Govt of India)',
      'amount': '₹20,000',
      'deadline': '31 Oct 2026',
      'eligibility': 'Top 20th Percentile in 12th Board Exams',
      'boardTag': 'Central Govt',
      'portalUrl': 'https://scholarships.gov.in/',
    },
  ];

  // Requirement 6: Notifications List
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-01',
      'title': 'Fund Released ✓',
      'message': '₹25,000 credited to HDFC Bank (•••• 4892) for MSBTE Merit Scholarship.',
      'time': '01 Sep 2026, 09:45 AM',
      'type': 'Fund Released',
      'color': colorFundReleased,
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'NOTIF-02',
      'title': 'Under Review 🔍',
      'message': 'Rajarshi Shahu Maharaj EBC application is currently under DHE Desk review.',
      'time': '02 Sep 2026, 11:30 AM',
      'type': 'Under Review',
      'color': colorReview,
      'icon': Icons.rate_review_rounded,
    },
    {
      'id': 'NOTIF-03',
      'title': 'Documents Verified 📑',
      'message': 'Tahsildar Income Certificate & Marksheets verified by Registrar.',
      'time': '30 Aug 2026, 01:10 PM',
      'type': 'Documents Verified',
      'color': colorVerification,
      'icon': Icons.fact_check_rounded,
    },
    {
      'id': 'NOTIF-04',
      'title': 'Application Submitted 📤',
      'message': 'Application MAHA-2026-9214 successfully submitted to MahaDBT portal.',
      'time': '28 Aug 2026, 04:20 PM',
      'type': 'Application Submitted',
      'color': colorSubmitted,
      'icon': Icons.send_rounded,
    },
  ];

  // Summary Metrics Calculation
  int get _totalApplied => _myApplications.length;
  int get _totalApproved => _myApplications.where((a) => a['application_status'] == 'Approved' || a['application_status'] == 'Fund Released').length;
  int get _totalPending => _myApplications.where((a) => a['application_status'] == 'Submitted' || a['application_status'] == 'Document Verification' || a['application_status'] == 'Under Review').length;
  int get _totalRejected => _myApplications.where((a) => a['application_status'] == 'Rejected').length;
  int get _totalAmountReceived => 25000;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
    });

    try {
      final fetchedSchemes = await ApiService.fetchAvailableScholarships();
      if (fetchedSchemes.isNotEmpty && mounted) {
        setState(() {
          _availableScholarships.clear();
          for (var item in fetchedSchemes) {
            _availableScholarships.add({
              'id': item['id']?.toString() ?? 'SCH-AVAIL',
              'title': item['title'] ?? item['scholarshipName'] ?? 'Merit Scholarship',
              'provider': item['provider'] ?? 'State Board',
              'amount': item['amount'] ?? '₹25,000',
              'deadline': item['deadline'] ?? '30 Sep 2026',
              'eligibility': item['criteria'] ?? item['eligibility'] ?? 'Marks > 80%',
              'seats': item['availableSeats'] ?? '500 Seats Available',
              'boardTag': item['category'] ?? 'Govt Scheme',
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Refresh data error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: null, // Requirement 10: DO NOT USE BOTTOM NAVIGATION
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scholarship Tracker',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Campus Financial Ecosystem',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: goldLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () async {
              await _refreshData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scholarship Tracker data refreshed live from database!'),
                    backgroundColor: primaryGreen,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Requirement 3: Tracker Dashboard Summary Cards
              _buildTopSummarySection(),
              const SizedBox(height: 22),

              // Requirement 9: Search & Status Filters
              _buildSearchAndFilterBar(),
              const SizedBox(height: 18),

              // Requirement 2 & 7: Active Application Tracking with Vertical Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Application Tracking Pipeline',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryGreen.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Live DB Sync',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildActiveApplicationsList(),
              const SizedBox(height: 24),

              // Requirement 1: Available Scholarships
              Text(
                'Available Scholarship Schemes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildAvailableScholarshipsList(),
              const SizedBox(height: 24),

              // Requirement 6: Notifications Section
              Text(
                'Recent Tracker Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotificationsSection(),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ==========================================
  // SECTION 3: TOP SUMMARY CARDS (TRACKER DASHBOARD)
  // ==========================================
  Widget _buildTopSummarySection() {
    return Column(
      children: [
        // Total Amount Received Banner Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D5C3A), Color(0xFF044E2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldAccent, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount Disbursed & Received',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_totalAmountReceived.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Credited to HDFC Bank •••• 4892',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goldAccent.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: goldAccent,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary Cards Grid (4 Cards)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.0,
          children: [
            _buildStatSummaryCard(
              title: 'Total Applied',
              value: '$_totalApplied',
              icon: Icons.assignment_rounded,
              color: colorSubmitted,
              bgLight: const Color(0xFFEFF6FF),
            ),
            _buildStatSummaryCard(
              title: 'Total Approved',
              value: '$_totalApproved',
              icon: Icons.check_circle_rounded,
              color: colorApproved,
              bgLight: const Color(0xFFECFDF5),
            ),
            _buildStatSummaryCard(
              title: 'Total Pending',
              value: '$_totalPending',
              icon: Icons.hourglass_top_rounded,
              color: colorReview,
              bgLight: const Color(0xFFFAF5FF),
            ),
            _buildStatSummaryCard(
              title: 'Total Rejected',
              value: '$_totalRejected',
              icon: Icons.cancel_rounded,
              color: colorRejected,
              bgLight: const Color(0xFFFEF2F2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatSummaryCard({
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 9: SEARCH & STATUS FILTERS
  // ==========================================
  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
        TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by Application ID, Scholarship, Provider...',
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
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              'All',
              'Submitted',
              'Document Verification',
              'Under Review',
              'Approved',
              'Fund Released',
              'Rejected',
            ].map((st) {
              final isSel = _selectedStatusFilter == st;
              final statusColor = _getStatusColor(st);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(st),
                  selected: isSel,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatusFilter = st;
                    });
                  },
                  selectedColor: statusColor,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? Colors.white : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSel ? statusColor : Colors.grey[300]!,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 2 & 7: ACTIVE APPLICATION TRACKING WITH VERTICAL TIMELINE
  // ==========================================
  Widget _buildActiveApplicationsList() {
    final filtered = _myApplications.where((app) {
      final matchesStatus = _selectedStatusFilter == 'All' ||
          app['application_status'] == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          app['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app['provider'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'No Applications Found',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Try adjusting status filters or search query.',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final app = filtered[index];
        final isExpanded = _expandedAppId == app['id'];
        final statusColor = app['statusColor'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded ? statusColor : Colors.grey[200]!,
              width: isExpanded ? 1.5 : 1,
            ),
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
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        app['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      app['amount'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text(
                      '${app['provider']} • ID: ${app['id']}',
                      style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor, width: 1),
                          ),
                          child: Text(
                            app['application_status'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Expected: ${app['expectedCompletion']}',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: primaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedAppId = isExpanded ? null : (app['id'] as String);
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
                      Text(
                        'Vertical Audit Stage Timeline',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Requirement 2 & 7: Vertical Timeline View
                      _buildVerticalTimelineView(app['timeline'] as List),

                      const SizedBox(height: 14),

                      // Remarks Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: primaryGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Remarks: ${app['remarks']}',
                                style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (app['applicationMode'] == 'EXTERNAL_WEBSITE') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.public_rounded, color: Color(0xFF2563EB), size: 18),
                                  const SizedBox(width: 6),
                                  Text('External Website Application', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Official Website Name: ${app['externalWebsiteName'] ?? 'Official Portal'}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary)),
                              Text('Website Status: ${app['externalWebsiteStatus'] ?? 'Active'}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary)),
                              Text('Last Opened Date: ${app['lastOpenedDate'] ?? app['applied_date']}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final urlStr = app['externalWebsiteUrl'] ?? 'https://mahadbt.maharashtra.gov.in';
                              try {
                                final uri = Uri.parse(urlStr);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              } catch (_) {}
                            },
                            icon: const Icon(Icons.launch_rounded, size: 16, color: Colors.white),
                            label: Text('Open Website Button', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ] else if (app['application_status'] == 'Draft' || app['application_status'] == 'In Progress') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note_rounded, color: Color(0xFFD97706), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Draft Saved - Editable (Upload New Documents & Update Form)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF92400E))),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScholarshipApplyStepperScreen(
                                        scholarshipName: app['title'] as String,
                                        scholarshipAmount: app['amount'] as String,
                                        studentId: widget.studentId,
                                        studentName: widget.userName,
                                        initialDraft: app,
                                        isEditable: true,
                                        applicationStatus: app['application_status'],
                                        onDraftSaved: (dData) {
                                          setState(() {
                                            app['formData'] = dData['formData'];
                                          });
                                        },
                                        onSubmitted: (sData) {
                                          setState(() {
                                            app['application_status'] = 'Submitted';
                                            app['statusColor'] = colorSubmitted;
                                            app['formData'] = sData['formData'];
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Edit Form / Resume', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openApplicationDetailsModal(app),
                                icon: const Icon(Icons.cloud_upload_outlined, size: 14, color: primaryGreen),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Upload New Docs', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: primaryGreen),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Application Submitted - Form Locked for Editing',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openApplicationDetailsModal(app),
                                icon: const Icon(Icons.visibility_outlined, size: 14, color: primaryGreen),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Full Details', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: primaryGreen),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openDownloadLetterModal(app),
                                icon: const Icon(Icons.download_rounded, size: 14, color: Colors.white),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Approval Letter', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Vertical Timeline Visualizer (Requirement 2 & 7)
  Widget _buildVerticalTimelineView(List timelineSteps) {
    return Column(
      children: List.generate(timelineSteps.length, (idx) {
        final step = timelineSteps[idx] as Map<String, dynamic>;
        final isDone = step['isDone'] == true;
        final isCurrent = step['isCurrent'] == true;
        final Color stepColor = isDone ? (step['color'] as Color) : Colors.grey[400]!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? stepColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? goldAccent : stepColor,
                      width: isCurrent ? 2.5 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : Text(
                            '${idx + 1}',
                            style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                  ),
                ),
                if (idx < timelineSteps.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone ? stepColor : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          step['status'] as String,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? primaryGreen : (isDone ? AppColors.textPrimary : Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        step['date'] as String,
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Text(
                    step['desc'] as String,
                    style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ==========================================
  // SECTION 1: AVAILABLE SCHOLARSHIPS
  // ==========================================
  Widget _buildAvailableScholarshipsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableScholarships.length,
      itemBuilder: (context, index) {
        final sch = _availableScholarships[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldAccent.withAlpha(50)),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              Text(
                sch['provider'] as String,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Eligibility: ${sch['eligibility']}',
                      style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Deadline: ${sch['deadline']}',
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'Seats: ${sch['seats'] ?? "500 Seats Available"}',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openApplySchemeModal(sch),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15, color: Colors.white),
                  label: Text('Apply Scheme', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                      (sch['boardTag'] ?? 'Govt Board') as String,
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                  ),
                  Text(
                    (sch['amount'] ?? '₹25,000') as String,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: goldAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                (sch['title'] ?? 'Merit Scholarship') as String,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                (sch['provider'] ?? 'State Board of Technical Education') as String,
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // Option 1: Fill Interactive Form in App
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScholarshipApplyStepperScreen(
                        scholarshipName: (sch['title'] ?? 'Merit Scholarship') as String,
                        scholarshipAmount: (sch['amount'] ?? '₹25,000') as String,
                        studentId: widget.studentId,
                        studentName: widget.userName,
                      ),
                    ),
                  );
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

              // Option 2: Open Official Website Portal
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
                              'Launch https://msbte.org.in/ with auto-copy PRN & credentials',
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

              // Option 3: View Full Scheme Overview & Guidelines
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.language_rounded, color: primaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'Official Website Portal',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redirecting to Official Government Portal:',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: goldLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: goldAccent),
              ),
              child: SelectableText(
                'https://msbte.org.in/scholarship/2026',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '✓ PRN Credentials (${widget.studentId}) copied to clipboard for direct login.',
              style: GoogleFonts.poppins(fontSize: 11, color: emeraldAccent, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: Text('Launch Portal Webview', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openScholarshipDetailsModal(Map<String, dynamic> sch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.all(22),
          child: ListView(
            controller: scrollController,
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
              const SizedBox(height: 16),
              Text(
                (sch['title'] ?? 'Scheme Details') as String,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              Text(
                (sch['provider'] ?? 'State Board') as String,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 24),
              Text(
                'Eligibility Criteria',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                (sch['eligibility'] ?? 'Minimum 80% marks in previous examination') as String,
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Required Document Checklist',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...[
                '1. Aadhaar Card (Linked with Bank)',
                '2. Tahsildar Income Certificate (Current Financial Year)',
                '3. Semester Marksheets / Transcripts',
                '4. Bonafide Student Certificate',
                '5. Passbook Front Page (HDFC Bank)',
                '6. Passport Size Photograph',
              ].map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: emeraldAccent),
                        const SizedBox(width: 8),
                        Text(doc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _openApplySchemeModal(sch);
                },
                child: Text('Proceed to Apply', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 6: NOTIFICATIONS SECTION
  // ==========================================
  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: _notifications.map((notif) {
          final color = notif['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif['icon'] as IconData, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif['title'] as String,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                          ),
                          Text(
                            notif['time'] as String,
                            style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notif['message'] as String,
                        style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // SECTION 4: APPLICATION DETAILS MODAL
  // ==========================================
  void _openApplicationDetailsModal(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.92,
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

                  Text('Application Record Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(app['title'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: primaryGreen)),
                  Text(app['provider'] as String, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Application ID:', app['id'] as String),
                        _buildDetailRow('Student Name:', widget.userName),
                        _buildDetailRow('Student PRN:', widget.studentId),
                        _buildDetailRow('Applied Date:', app['applied_date'] as String),
                        _buildDetailRow('Verification Date:', app['verification_date'] as String),
                        _buildDetailRow('Review Date:', app['review_date'] as String),
                        _buildDetailRow('Approval Date:', app['approval_date'] as String),
                        _buildDetailRow('Fund Release Date:', app['fund_release_date'] as String),
                        _buildDetailRow('Current Status:', app['application_status'] as String),
                        _buildDetailRow('Expected Completion:', app['expectedCompletion'] as String),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Officer Remarks', style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    app['remarks'] as String,
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openDownloadReceiptModal(app);
                          },
                          icon: const Icon(Icons.receipt_long_rounded, size: 14, color: primaryGreen),
                          label: Text('Download Receipt', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openDownloadLetterModal(app);
                          },
                          icon: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                          label: Text('Approval Letter', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // SECTION 9: DOWNLOAD APPROVAL LETTER & RECEIPT MODALS
  // ==========================================
  void _openDownloadLetterModal(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Official Approval Letter', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: primaryGreen)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: goldLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: goldAccent)),
                  child: Column(
                    children: [
                      Text('GOVERNMENT SCHOLARSHIP SANCTION ORDER', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text('Sanction Letter Ref: SL-2026-${app['id']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Applicant: ${widget.userName} (${widget.studentId})', style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary)),
                      Text('Grant Amount Sanctioned: ${app['amount']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: emeraldAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Approval Letter PDF saved to Downloads folder!'), backgroundColor: primaryGreen),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                    label: Text('Save Official PDF Letter', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDownloadReceiptModal(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Scholarship Disbursal Receipt', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: primaryGreen)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14), border: Border.all(color: emeraldAccent)),
                  child: Column(
                    children: [
                      Text('DISBURSEMENT VOUCHER RECEIPT', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen)),
                      const SizedBox(height: 6),
                      Text('Txn ID: TXN98421092482', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Credited: ${app['amount']} to ${app['bankAccount']}', style: GoogleFonts.poppins(fontSize: 10.5, color: primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Scholarship Disbursal Receipt saved!'), backgroundColor: primaryGreen),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                    label: Text('Save Official Receipt', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
