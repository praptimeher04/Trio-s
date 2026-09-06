import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/session_service.dart';
import 'reseller_dashboard_screen.dart';
import '../widgets/logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final List<Map<String, String>> favoriteProducts;
  final Function(Map<String, String>)? onRemoveFavorite;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userRole = 'Student',
    this.favoriteProducts = const [],
    this.onRemoveFavorite,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;

  late String _currentName;
  late String _currentEmail;
  String _department = 'Computer Science';
  String _semester = 'Year 3 / S6';
  String _campusLocation = 'North Campus';
  String _phone = '+91 98765 43210';
  String _bio = '"Code, coffee & sustainable tech enthusiast. Always learning."';
  String _aboutMe = 'Final year engineering student building accessible campus solutions. Active on the intra-campus peer marketplace to recycle electronics, reference textbooks, and maker modules.';

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName.isNotEmpty ? widget.userName : 'Jay';
    _currentEmail = widget.userEmail.isNotEmpty ? widget.userEmail : 'jay@gmail.com';
  }

  String get _initials {
    final name = _currentName.trim();
    if (name.isEmpty) return 'JA';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E2235);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF8F94A6);
    final bgContainer = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bgContainer,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. AVATAR & HEADER SECTION WITH RAINBOW BORDER
                _buildAvatarHeaderSection(isDark, textPrimary, textSecondary),
                const SizedBox(height: 18),

                // 2. ACADEMIC ATTRIBUTE PILLS
                _buildAcademicPillsRow(isDark, cardBg, textSecondary),
                const SizedBox(height: 18),

                // 3. KEY METRICS STATS ROW (3 COLUMNS)
                _buildMetricsStatsCard(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 18),

                // 4. ACTION BUTTONS (EDIT PROFILE & CAMPUS STATS)
                _buildActionButtonsGroup(context, isDark, cardBg, textPrimary),
                const SizedBox(height: 20),

                // 5. ABOUT ME SECTION
                _buildAboutMeSection(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 18),

                // 6. INTERESTS & TAGS SECTION
                _buildInterestsTagsSection(isDark, textPrimary),
                const SizedBox(height: 20),

                // 7. CURRENT RESALE ITEM CARD & MARKETPLACE PURCHASES
                _buildCurrentResaleCard(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 20),

                // 8. DIGITAL CAMPUS PASS CARD
                _buildSectionHeader('Digital Campus Pass', textPrimary),
                const SizedBox(height: 8),
                _buildDigitalPassCard(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 20),

                // 9. FAVORITE PRODUCTS SECTION
                if (widget.favoriteProducts.isNotEmpty) ...[
                  _buildSectionHeader('Saved Favorite Products (${widget.favoriteProducts.length})', textPrimary),
                  const SizedBox(height: 8),
                  _buildFavoritesCard(isDark, cardBg, textPrimary, textSecondary),
                  const SizedBox(height: 20),
                ],

                // 10. PREFERENCES & SECURITY
                _buildSectionHeader('Preferences & Security', textPrimary),
                const SizedBox(height: 8),
                _buildPreferencesCard(isDark, cardBg, textPrimary, textSecondary),
                const SizedBox(height: 24),

                // 11. SWITCH TO RESELLER & LOGOUT
                _buildBottomAccountActions(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. AVATAR & HEADER SECTION ---
  Widget _buildAvatarHeaderSection(bool isDark, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Left Orbit Badge (ID)
            Positioned(
              left: -32,
              top: 24,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF43F5E), Color(0xFFEC4899)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'ID',
                  style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),

            // Right Orbit Badge (Sparkle)
            Positioned(
              right: -32,
              top: 24,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF22D3EE), Color(0xFF3B82F6), Color(0xFF4F46E5)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
              ),
            ),

            // Main Emerald Mint Border Circle around Avatar
            Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF047857),
                    Color(0xFF34D399),
                    Color(0xFF059669),
                    Color(0xFF10B981),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x38059669),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _initials,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name & Department Headline
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '|',
                style: GoogleFonts.poppins(fontSize: 16, color: isDark ? Colors.white38 : const Color(0xFFD6D3D1)),
              ),
            ),
            Text(
              _department,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF57534E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Bio Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _bio,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. ACADEMIC ATTRIBUTE PILLS ---
  Widget _buildAcademicPillsRow(bool isDark, Color cardBg, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPillItem(
          icon: Icons.school_rounded,
          iconColor: const Color(0xFFEC4899),
          label: _semester,
          isDark: isDark,
          cardBg: cardBg,
          textSecondary: textSecondary,
        ),
        const SizedBox(width: 28),
        _buildPillItem(
          icon: Icons.account_balance_rounded,
          iconColor: const Color(0xFFF59E0B),
          label: _campusLocation,
          isDark: isDark,
          cardBg: cardBg,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  Widget _buildPillItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isDark,
    required Color cardBg,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // --- 3. KEY METRICS STATS ROW ---
  Widget _buildMetricsStatsCard(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildMetricColumn('8', 'Purchases', textPrimary, textSecondary, () => _showMyOrdersModal(context))),
          Container(height: 28, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
          Expanded(child: _buildMetricColumn('3', 'Active Resale', textPrimary, textSecondary, () => _showMyListingsModal(context))),
          Container(height: 28, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
          Expanded(child: _buildMetricColumn('₹12,450', 'Total Saved', textPrimary, textSecondary, () => _showDigitalIdModal(context))),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String val, String label, Color textPrimary, Color textSecondary, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. ACTION BUTTONS GROUP ---
  Widget _buildActionButtonsGroup(BuildContext context, bool isDark, Color cardBg, Color textPrimary) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _showEditProfileModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 20 : 8),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _showDigitalIdModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Campus Stats',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. ABOUT ME SECTION ---
  Widget _buildAboutMeSection(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT ME',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            _aboutMe,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C),
            ),
          ),
        ),
      ],
    );
  }

  // --- 6. INTERESTS & TAGS SECTION ---
  Widget _buildInterestsTagsSection(bool isDark, Color textPrimary) {
    final tags = [
      {'label': 'Tech & IoT', 'bg': const Color(0xFFECFDF5), 'text': const Color(0xFF047857)},
      {'label': 'Textbooks', 'bg': const Color(0xFFE0F2FE), 'text': const Color(0xFF0369A1)},
      {'label': 'Robotics', 'bg': const Color(0xFFD1FAE5), 'text': const Color(0xFF065F46)},
      {'label': 'Web3 / Dev', 'bg': const Color(0xFFFEF3C7), 'text': const Color(0xFF92400E)},
      {'label': 'Design', 'bg': const Color(0xFFF1F5F9), 'text': const Color(0xFF334155)},
      {'label': 'Hackathons', 'bg': const Color(0xFFE0E7FF), 'text': const Color(0xFF3730A3)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INTERESTS & TAGS',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? (t['text'] as Color).withAlpha(40) : (t['bg'] as Color),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : (t['text'] as Color),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 7. CURRENT RESALE ITEM CARD ---
  Widget _buildCurrentResaleCard(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CURRENT RESALE ITEM',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showMyListingsModal(context),
              child: Text(
                'View All (3)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CALC',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Casio FX-991EX Scientific Calc',
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
                      'Semester 4 • Excellent Condition',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹750',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 8. DIGITAL CAMPUS PASS CARD ---
  Widget _buildDigitalPassCard(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.qr_code_2_rounded, size: 48, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Digital Student Pass',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                Text(
                  'Roll #: 2026-CS-892 • Gate & Library Pass',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: textSecondary),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showDigitalIdModal(context),
                  child: Text(
                    'View Digital ID Card ➔',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 9. FAVORITE PRODUCTS CARD ---
  Widget _buildFavoritesCard(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
      ),
      child: Column(
        children: widget.favoriteProducts.map((prod) {
          final title = prod['title'] ?? '';
          final price = prod['price'] ?? '';
          final seller = prod['seller'] ?? '';
          final image = prod['image'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (image != null && image.isNotEmpty)
                      ? Image.network(
                          image,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 44,
                            height: 44,
                            color: const Color(0xFFECFDF5),
                            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF059669), size: 20),
                          ),
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFECFDF5),
                          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF059669), size: 20),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('$price • $seller', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 18),
                  onPressed: () {
                    if (widget.onRemoveFavorite != null) {
                      widget.onRemoveFavorite!(prod);
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 10. PREFERENCES CARD ---
  Widget _buildPreferencesCard(bool isDark, Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F5F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text('Push Notifications', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
                ],
              ),
              Switch(
                value: _notificationsEnabled,
                activeTrackColor: const Color(0xFF059669),
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ],
          ),
          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.fingerprint_rounded, color: textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text('Fingerprint / Face ID', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
                ],
              ),
              Switch(
                value: _biometricEnabled,
                activeTrackColor: const Color(0xFF059669),
                onChanged: (val) => setState(() => _biometricEnabled = val),
              ),
            ],
          ),
          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dark_mode_rounded, color: textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text('Dark Appearance Mode', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
                ],
              ),
              Switch(
                value: themeNotifier.value == ThemeMode.dark,
                activeTrackColor: const Color(0xFF059669),
                onChanged: (val) {
                  setState(() {
                    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? '🌙 Dark mode enabled across entire app!' : '☀️ Light mode enabled!'),
                      backgroundColor: const Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 16),

          _buildSettingTile(Icons.lock_reset_rounded, 'Change Password', textPrimary, textSecondary, () => _showChangePasswordModal(context)),
          const Divider(height: 16),
          _buildSettingTile(Icons.help_outline_rounded, 'Campus Help & Support Desk', textPrimary, textSecondary, () => _showHelpSupportModal(context)),
        ],
      ),
    );
  }

  // --- 11. BOTTOM ACCOUNT ACTIONS ---
  Widget _buildBottomAccountActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final session = await SessionService.getSession();
            final int? userId = session['userId'] != null ? int.tryParse(session['userId'].toString()) : null;

            if (!context.mounted) return;

            await SessionService.saveSession(
              isLoggedIn: true,
              userId: userId,
              userType: 1,
              userName: _currentName,
              userEmail: _currentEmail,
              userRole: 'Reseller',
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🔄 Switched to Reseller Panel (Type 1) - Welcome $_currentName!'),
                  backgroundColor: const Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ResellerDashboardScreen(
                    resellerName: _currentName,
                    resellerEmail: _currentEmail,
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
          label: const Text('Switch / Swap to Reseller Panel (Type 1)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B6E4F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () => showLogoutConfirmationDialog(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: const Text('Sign Out of Account'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSectionHeader(String title, Color textPrimary) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textPrimary,
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Color textPrimary, Color textSecondary, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
        ],
      ),
    );
  }

  // --- MODALS ---
  void _showEditProfileModal(BuildContext context) {
    final nameCtrl = TextEditingController(text: _currentName);
    final phoneCtrl = TextEditingController(text: _phone);
    final deptCtrl = TextEditingController(text: _department);
    final semCtrl = TextEditingController(text: _semester);
    final locCtrl = TextEditingController(text: _campusLocation);
    final bioCtrl = TextEditingController(text: _bio);
    final aboutCtrl = TextEditingController(text: _aboutMe);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Student Profile', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 10),
              TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.school_outlined))),
              const SizedBox(height: 10),
              TextField(controller: semCtrl, decoration: const InputDecoration(labelText: 'Semester / Year', prefixIcon: Icon(Icons.calendar_today_outlined))),
              const SizedBox(height: 10),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Campus Location', prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 10),
              TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Short Bio Quote', prefixIcon: Icon(Icons.format_quote_outlined))),
              const SizedBox(height: 10),
              TextField(controller: aboutCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'About Me Description', prefixIcon: Icon(Icons.info_outline_rounded))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentName = nameCtrl.text.trim();
                      _phone = phoneCtrl.text.trim();
                      _department = deptCtrl.text.trim();
                      _semester = semCtrl.text.trim();
                      _campusLocation = locCtrl.text.trim();
                      _bio = bioCtrl.text.trim();
                      _aboutMe = aboutCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Profile details updated successfully!')),
                    );
                  },
                  child: const Text('Save Profile Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDigitalIdModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text('NATIONAL INSTITUTE OF TECHNOLOGY', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text('STUDENT IDENTITY PASS', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(_initials, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                  ),
                  const SizedBox(height: 10),
                  Text(_currentName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(_currentEmail, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    child: Text('Roll #: 2026-CS-892 • $_department', style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.qr_code_2_rounded, size: 90, color: Color(0xFF0F172A)),
            Text('Scan at Canteen, Library & Gate', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close ID Card', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyOrdersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Marketplace Purchases (8)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _buildOrderItem('Data Structures & Algorithms (Cormen)', '₹350', 'Delivered • 4 Sep 2026'),
            _buildOrderItem('Casio Scientific Calculator FX-991EX', '₹600', 'Delivered • 2 Sep 2026'),
            _buildOrderItem('Semester 5 Handwritten Notes', '₹150', 'Delivered • 28 Aug 2026'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Orders')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(status, style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF059669))),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
        ],
      ),
    );
  }

  void _showMyListingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Listed Items for Sale (3)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _buildListingItem('Engineering Drawing Kit', '₹450', 'Active Listing'),
            _buildListingItem('Physics Lab Coat (Size M)', '₹200', 'Active Listing'),
            _buildListingItem('Organic Chemistry Textbook', '₹300', 'Active Listing'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Listings')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingItem(String title, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(status, style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF2563EB))),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 10),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'New Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔒 Password updated successfully!')),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus Support Desk 🎧', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Need assistance with transactions, chat, or orders? We are here 24/7!', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
            const SizedBox(height: 16),
            _buildSupportTile(Icons.email_outlined, 'Support Email', 'support@campusapp.edu'),
            _buildSupportTile(Icons.phone_in_talk_outlined, 'Campus Helpline', '+91 1800-123-4567'),
            _buildSupportTile(Icons.chat_bubble_outline_rounded, 'Live Chat Assistant', 'Average response time: 2 mins'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF059669), size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}
