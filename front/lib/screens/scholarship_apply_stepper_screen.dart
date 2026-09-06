import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ScholarshipApplyStepperScreen extends StatefulWidget {
  final String scholarshipName;
  final String scholarshipAmount;
  final String studentId;
  final String studentName;
  final Map<String, dynamic>? initialDraft;
  final bool isEditable;
  final String applicationStatus;
  final Function(Map<String, dynamic> appData)? onDraftSaved;
  final Function(Map<String, dynamic> appData)? onSubmitted;

  const ScholarshipApplyStepperScreen({
    super.key,
    this.scholarshipName = 'MSBTE Diploma & Degree Merit Scholarship',
    this.scholarshipAmount = '₹25,000',
    this.studentId = 'CMP-2026-8910',
    this.studentName = 'Hitija Mhatre',
    this.initialDraft,
    this.isEditable = true,
    this.applicationStatus = 'Draft',
    this.onDraftSaved,
    this.onSubmitted,
  });

  @override
  State<ScholarshipApplyStepperScreen> createState() => _ScholarshipApplyStepperScreenState();
}

class _ScholarshipApplyStepperScreenState extends State<ScholarshipApplyStepperScreen> {
  int _currentStep = 0; // 0 to 5 (Steps 1 to 6)
  bool _isSavingDraft = false;
  bool _draftSaved = false;
  bool _isSubmitting = false;

  // Step 1 - Personal Details
  late TextEditingController _fullNameController;
  late TextEditingController _studentIdController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  String _selectedGender = 'Female';
  late TextEditingController _dobController;
  late TextEditingController _addressController;

  // Step 2 - Academic Details
  late TextEditingController _collegeController;
  late TextEditingController _departmentController;
  String _selectedCourse = 'B.Tech / B.E. Computer Engineering';
  String _selectedSemester = 'Semester 6 (3rd Year)';
  late TextEditingController _cgpaController;
  late TextEditingController _prevPercentageController;

  // Step 3 - Family Details
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _familyIncomeController;
  late TextEditingController _occupationController;

  // Step 4 - Bank Details
  late TextEditingController _accountHolderController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;

  // Step 5 - Document Uploads (Simulated Upload state with Progress)
  final Map<String, Map<String, dynamic>> _documents = {
    'Aadhaar Card': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'Aadhaar_Hitija_Mhatre.pdf'},
    'Income Certificate': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'Tahsildar_Income_2026.pdf'},
    'Bonafide Certificate': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'Campus_Bonafide_2026.pdf'},
    'Marksheet': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'Sem5_Official_Marksheet.pdf'},
    'Bank Passbook': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'HDFC_Passbook_Front.pdf'},
    'Passport Photo': {'status': 'Uploaded', 'progress': 1.0, 'fileName': 'Hitija_Photo_Passport.jpg'},
  };

  // Light Green FinTech Palette (#10B981 / #059669 / #ECFDF5)
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color emeraldAccent = Color(0xFF059669);
  static const Color cardBg = Colors.white;
  static const Color bgGrey = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    final draftData = widget.initialDraft?['formData'] as Map<String, dynamic>? ?? {};

    _fullNameController = TextEditingController(text: draftData['fullName'] ?? widget.studentName);
    _studentIdController = TextEditingController(text: draftData['studentId'] ?? widget.studentId);
    _emailController = TextEditingController(text: draftData['email'] ?? 'hitija.mhatre@campus.edu.in');
    _mobileController = TextEditingController(text: draftData['mobile'] ?? '+91 98201 48920');
    _dobController = TextEditingController(text: draftData['dob'] ?? '14/05/2004');
    _addressController = TextEditingController(text: draftData['address'] ?? 'Flat 402, Green Valley Towers, Sector 12, Navi Mumbai, MS');

    _collegeController = TextEditingController(text: draftData['college'] ?? 'Campus Institute of Technology & Engineering');
    _departmentController = TextEditingController(text: draftData['department'] ?? 'Computer Science & Engineering');
    _cgpaController = TextEditingController(text: draftData['cgpa'] ?? '8.85');
    _prevPercentageController = TextEditingController(text: draftData['prevPercentage'] ?? '86.40%');

    if (draftData['course'] != null) _selectedCourse = draftData['course'];
    if (draftData['semester'] != null) _selectedSemester = draftData['semester'];
    if (draftData['gender'] != null) _selectedGender = draftData['gender'];

    _fatherNameController = TextEditingController(text: draftData['fatherName'] ?? 'Rajesh Mhatre');
    _motherNameController = TextEditingController(text: draftData['motherName'] ?? 'Sunita Mhatre');
    _familyIncomeController = TextEditingController(text: draftData['familyIncome'] ?? '₹3,50,000 / Year');
    _occupationController = TextEditingController(text: draftData['occupation'] ?? 'Government Service / Business');

    _accountHolderController = TextEditingController(text: draftData['accountHolder'] ?? widget.studentName);
    _bankNameController = TextEditingController(text: draftData['bankName'] ?? 'HDFC Bank Ltd (Campus Branch)');
    _accountNumberController = TextEditingController(text: draftData['accountNumber'] ?? '50100293849102');
    _ifscCodeController = TextEditingController(text: draftData['ifsc'] ?? 'HDFC0001294');

    _triggerAutoSave();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    _cgpaController.dispose();
    _prevPercentageController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _familyIncomeController.dispose();
    _occupationController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  void _triggerAutoSave() {
    setState(() {
      _isSavingDraft = true;
      _draftSaved = false;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _draftSaved = true;
        });
      }
    });
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      _triggerAutoSave();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _triggerAutoSave();
    }
  }

  void _jumpToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _triggerAutoSave();
  }

  Future<void> _saveDraftExplicit() async {
    setState(() {
      _isSavingDraft = true;
    });

    final payload = {
      'scholarshipName': widget.scholarshipName,
      'studentId': widget.studentId,
      'studentName': widget.studentName,
      'applicationStatus': 'Draft',
      'appliedDate': DateTime.now().toIso8601String(),
      'formData': {
        'fullName': _fullNameController.text,
        'studentId': _studentIdController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
        'gender': _selectedGender,
        'dob': _dobController.text,
        'address': _addressController.text,
        'college': _collegeController.text,
        'department': _departmentController.text,
        'course': _selectedCourse,
        'semester': _selectedSemester,
        'cgpa': _cgpaController.text,
        'prevPercentage': _prevPercentageController.text,
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
        'familyIncome': _familyIncomeController.text,
        'occupation': _occupationController.text,
        'accountHolder': _accountHolderController.text,
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumberController.text,
        'ifsc': _ifscCodeController.text,
      },
      'documents': _documents,
    };

    await ApiService.saveScholarshipDraft(payload);

    if (widget.onDraftSaved != null) {
      widget.onDraftSaved!(payload);
    }

    if (mounted) {
      setState(() {
        _isSavingDraft = false;
        _draftSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draft saved! You can resume and update your application anytime.', style: GoogleFonts.poppins()),
          backgroundColor: primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _submitApplication() async {
    if (!widget.isEditable && widget.applicationStatus != 'Draft' && widget.applicationStatus != 'In Progress') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This application is ${widget.applicationStatus} and locked for editing.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      'scholarshipName': widget.scholarshipName,
      'studentId': widget.studentId,
      'studentName': widget.studentName,
      'applicationStatus': 'Submitted',
      'appliedDate': DateTime.now().toIso8601String(),
      'formData': {
        'fullName': _fullNameController.text,
        'studentId': _studentIdController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
        'gender': _selectedGender,
        'dob': _dobController.text,
        'address': _addressController.text,
        'college': _collegeController.text,
        'department': _departmentController.text,
        'course': _selectedCourse,
        'semester': _selectedSemester,
        'cgpa': _cgpaController.text,
        'prevPercentage': _prevPercentageController.text,
        'fatherName': _fatherNameController.text,
        'motherName': _motherNameController.text,
        'familyIncome': _familyIncomeController.text,
        'occupation': _occupationController.text,
        'accountHolder': _accountHolderController.text,
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumberController.text,
        'ifsc': _ifscCodeController.text,
      },
      'documents': _documents,
    };

    final result = await ApiService.submitScholarshipApplication(payload);

    if (widget.onSubmitted != null) {
      widget.onSubmitted!(payload);
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    // Show success modal then redirect to Scholarship Tracker
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: emeraldAccent, size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              'Application Submitted Successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Application ID: SCH-2026-${result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString().substring(7)}\nStatus updated to Submitted inside the application.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context, true); // Return to caller with true status
                },
                child: Text(
                  'Open Application Tracker',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scholarship Application Portal',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.scholarshipName,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isSavingDraft ? Icons.sync_rounded : Icons.cloud_done_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _isSavingDraft ? 'Saving...' : _draftSaved ? 'Draft Saved ✓' : 'Auto-Saved',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Header
            _buildStepperHeader(),

            // Form Content Step Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStepView(),
              ),
            ),

            // Bottom Navigation Buttons (Previous / Next / Submit)
            _buildBottomNavButtons(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP STEPPER HEADER
  // ==========================================
  Widget _buildStepperHeader() {
    final List<String> stepTitles = [
      'Personal',
      'Academic',
      'Family',
      'Bank',
      'Documents',
      'Review',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Flexible(
            child: GestureDetector(
              onTap: () {
                if (index <= _currentStep || isCompleted) {
                  _jumpToStep(index);
                }
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? emeraldAccent
                          : isActive
                              ? primaryGreen
                              : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: primaryGreen.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepTitles[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? primaryGreen
                          : isCompleted
                              ? emeraldAccent
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // STEP ROUTER SWITCH
  // ==========================================
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Personal();
      case 1:
        return _buildStep2Academic();
      case 2:
        return _buildStep3Family();
      case 3:
        return _buildStep4Bank();
      case 4:
        return _buildStep5Documents();
      case 5:
        return _buildStep6Review();
      default:
        return _buildStep1Personal();
    }
  }

  // ------------------------------------------
  // STEP 1: PERSONAL DETAILS
  // ------------------------------------------
  Widget _buildStep1Personal() {
    return _buildCardWrapper(
      title: 'Step 1: Personal Details',
      icon: Icons.person_rounded,
      children: [
        _buildTextField('Full Name', _fullNameController, Icons.badge_outlined),
        const SizedBox(height: 14),
        _buildTextField('Student ID / Enrollment Number', _studentIdController, Icons.fingerprint_rounded),
        const SizedBox(height: 14),
        _buildTextField('Email Address', _emailController, Icons.email_outlined),
        const SizedBox(height: 14),
        _buildTextField('Mobile Number', _mobileController, Icons.phone_android_rounded),
        const SizedBox(height: 14),
        Text('Gender', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Row(
          children: ['Female', 'Male', 'Other'].map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(gender),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedGender = gender);
                      _triggerAutoSave();
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _buildTextField('Date of Birth', _dobController, Icons.cake_outlined),
        const SizedBox(height: 14),
        _buildTextField('Residential Address', _addressController, Icons.home_outlined, maxLines: 3),
      ],
    );
  }

  // ------------------------------------------
  // STEP 2: ACADEMIC DETAILS
  // ------------------------------------------
  Widget _buildStep2Academic() {
    return _buildCardWrapper(
      title: 'Step 2: Academic Details',
      icon: Icons.school_rounded,
      children: [
        _buildTextField('College / Institute Name', _collegeController, Icons.account_balance_outlined),
        const SizedBox(height: 14),
        _buildTextField('Department / Discipline', _departmentController, Icons.domain_outlined),
        const SizedBox(height: 14),
        Text('Course', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourse,
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              items: [
                'B.Tech / B.E. Computer Engineering',
                'B.Tech Information Technology',
                'Diploma Engineering (MSBTE)',
                'M.Tech Computer Science',
                'B.Sc Data Science & AI',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCourse = val);
                  _triggerAutoSave();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Current Semester / Year', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSemester,
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              items: [
                'Semester 1 (1st Year)',
                'Semester 2 (1st Year)',
                'Semester 3 (2nd Year)',
                'Semester 4 (2nd Year)',
                'Semester 5 (3rd Year)',
                'Semester 6 (3rd Year)',
                'Semester 7 (4th Year)',
                'Semester 8 (4th Year)',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedSemester = val);
                  _triggerAutoSave();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildTextField('Current Cumulative CGPA', _cgpaController, Icons.grade_outlined),
        const SizedBox(height: 14),
        _buildTextField('Previous Year Percentage (%)', _prevPercentageController, Icons.percent_rounded),
      ],
    );
  }

  // ------------------------------------------
  // STEP 3: FAMILY DETAILS
  // ------------------------------------------
  Widget _buildStep3Family() {
    return _buildCardWrapper(
      title: 'Step 3: Family Details',
      icon: Icons.family_restroom_rounded,
      children: [
        _buildTextField("Father's / Guardian Name", _fatherNameController, Icons.person_outline_sharp),
        const SizedBox(height: 14),
        _buildTextField("Mother's Name", _motherNameController, Icons.person_outline_sharp),
        const SizedBox(height: 14),
        _buildTextField('Annual Family Income', _familyIncomeController, Icons.payments_outlined),
        const SizedBox(height: 14),
        _buildTextField('Parent Occupation', _occupationController, Icons.work_outline_rounded),
      ],
    );
  }

  // ------------------------------------------
  // STEP 4: BANK DETAILS
  // ------------------------------------------
  Widget _buildStep4Bank() {
    return _buildCardWrapper(
      title: 'Step 4: Bank Details for Disbursal',
      icon: Icons.account_balance_rounded,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Scholarship funds will be directly credited (DBT) to this verified bank account upon approval.',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        _buildTextField('Account Holder Name', _accountHolderController, Icons.person_pin_rounded),
        const SizedBox(height: 14),
        _buildTextField('Bank Name', _bankNameController, Icons.account_balance_outlined),
        const SizedBox(height: 14),
        _buildTextField('Bank Account Number', _accountNumberController, Icons.numbers_rounded),
        const SizedBox(height: 14),
        _buildTextField('IFSC Code', _ifscCodeController, Icons.qr_code_scanner_rounded),
      ],
    );
  }

  // ------------------------------------------
  // STEP 5: DOCUMENT UPLOADS WITH PROGRESS
  // ------------------------------------------
  Widget _buildStep5Documents() {
    return _buildCardWrapper(
      title: 'Step 5: Document Uploads',
      icon: Icons.cloud_upload_rounded,
      children: [
        Text(
          'Upload official PDF/Image copies of documents (Max 5MB each). Upload progress is tracked below.',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Column(
          children: _documents.entries.map((entry) {
            final docTitle = entry.key;
            final docData = entry.value;
            final double progress = docData['progress'] as double;
            final String fileName = docData['fileName'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file_rounded, color: primaryGreen, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              docTitle,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              fileName,
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: emeraldAccent, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '100% Uploaded',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: emeraldAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFCBD5E1),
                      color: emeraldAccent,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ------------------------------------------
  // STEP 6: REVIEW & SUBMIT
  // ------------------------------------------
  Widget _buildStep6Review() {
    return Column(
      children: [
        _buildReviewSection(
          stepIndex: 0,
          title: 'Personal Details',
          icon: Icons.person_rounded,
          items: {
            'Full Name': _fullNameController.text,
            'Student ID': _studentIdController.text,
            'Email': _emailController.text,
            'Mobile': _mobileController.text,
            'Gender': _selectedGender,
            'Date of Birth': _dobController.text,
            'Address': _addressController.text,
          },
        ),
        const SizedBox(height: 14),
        _buildReviewSection(
          stepIndex: 1,
          title: 'Academic Details',
          icon: Icons.school_rounded,
          items: {
            'College': _collegeController.text,
            'Department': _departmentController.text,
            'Course': _selectedCourse,
            'Semester': _selectedSemester,
            'CGPA': _cgpaController.text,
            'Previous Year %': _prevPercentageController.text,
          },
        ),
        const SizedBox(height: 14),
        _buildReviewSection(
          stepIndex: 2,
          title: 'Family Details',
          icon: Icons.family_restroom_rounded,
          items: {
            'Father Name': _fatherNameController.text,
            'Mother Name': _motherNameController.text,
            'Family Income': _familyIncomeController.text,
            'Occupation': _occupationController.text,
          },
        ),
        const SizedBox(height: 14),
        _buildReviewSection(
          stepIndex: 3,
          title: 'Bank Account Details',
          icon: Icons.account_balance_rounded,
          items: {
            'Account Holder': _accountHolderController.text,
            'Bank Name': _bankNameController.text,
            'Account Number': _accountNumberController.text,
            'IFSC Code': _ifscCodeController.text,
          },
        ),
        const SizedBox(height: 14),
        _buildReviewSection(
          stepIndex: 4,
          title: 'Documents Uploaded (6 Files)',
          icon: Icons.verified_user_rounded,
          items: {
            'Aadhaar Card': _documents['Aadhaar Card']!['fileName'],
            'Income Cert': _documents['Income Certificate']!['fileName'],
            'Bonafide': _documents['Bonafide Certificate']!['fileName'],
            'Marksheet': _documents['Marksheet']!['fileName'],
            'Bank Passbook': _documents['Bank Passbook']!['fileName'],
            'Photo': _documents['Passport Photo']!['fileName'],
          },
        ),
      ],
    );
  }

  Widget _buildReviewSection({
    required int stepIndex,
    required String title,
    required IconData icon,
    required Map<String, String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _jumpToStep(stepIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 14, color: emeraldAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: emeraldAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...items.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER UI COMPONENTS
  // ==========================================
  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          onChanged: (_) => _triggerAutoSave(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryGreen, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION BUTTONS
  // ==========================================
  Widget _buildBottomNavButtons() {
    final bool isLastStep = _currentStep == 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  side: const BorderSide(color: primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _previousStep,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Previous',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSavingDraft ? null : _saveDraftExplicit,
              icon: const Icon(Icons.bookmark_border_rounded, size: 15, color: Color(0xFFB45309)),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Save Draft',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFB45309)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? emeraldAccent : primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting
                  ? null
                  : isLastStep
                      ? _submitApplication
                      : _nextStep,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastStep ? 'Submit Application' : 'Next Step',
                            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isLastStep ? Icons.send_rounded : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
