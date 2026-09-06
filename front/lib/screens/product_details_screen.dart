import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/razorpay_payment_modal.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, String> product;
  final String userName;
  final String userEmail;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.userName = 'Hitija Mhatre',
    this.userEmail = 'student@campus.edu',
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isSaved = false;

  String get _title => widget.product['title'] ?? 'Campus Item';
  String get _price => widget.product['price'] ?? '₹0';
  String get _seller => widget.product['seller'] ?? 'Campus Peer';
  String get _tag => widget.product['tag'] ?? 'General';
  String get _condition => widget.product['condition'] ?? 'Good';
  String get _avatar => widget.product['avatar'] ?? (_seller.isNotEmpty ? _seller[0].toUpperCase() : 'S');
  String? get _image => widget.product['image'];

  String get _description {
    if (widget.product['description'] != null && widget.product['description']!.isNotEmpty) {
      return widget.product['description']!;
    }
    if (_title.contains('Cormen') || _title.contains('Textbook')) {
      return 'Introduction to Algorithms (CLRS) 3rd Edition. No pencil marks or folded pages. Perfect for semester 3 & 4 lab exams.';
    } else if (_title.contains('Bicycle')) {
      return 'Single-speed Hero Sprint bicycle with bell and front basket. Recently greased chain and fresh brake pads.';
    } else if (_title.contains('Calculator')) {
      return 'ClassWiz scientific calculator with solar panel backup. Allowed in end-semester exams. Hard cover included.';
    } else if (_title.contains('Lab Coat')) {
      return 'Standard white cotton unisex lab coat (Size M) with campus-approved anti-fog chemistry safety goggles.';
    } else if (_title.contains('Drawing Kit')) {
      return 'Complete first-year engineering kit: 60cm acrylic T-square, mini drafter, set squares, and compass set with storage bag.';
    } else if (_title.contains('Arduino')) {
      return 'Includes genuine Arduino Uno R3 board, jumper wires, breadboard, ultrasonic sensor, IR module, and USB cable.';
    } else {
      return 'High quality item verified by campus peers. Inspected for functionality and ready for immediate handover within the university campus.';
    }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isSaved ? const Color(0xFF0B6E4F) : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSaved ? 'Saved to your wishlist!' : 'Removed from wishlist.'),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VERIFIED STUDENT SELLER BADGE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF047857)),
                          const SizedBox(width: 6),
                          Text(
                            'Verified Student Seller',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PRODUCT IMAGE PREVIEW
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: 230,
                      color: const Color(0xFFF3F4F6),
                      child: _image != null && _image!.isNotEmpty
                          ? Image.network(
                              _image!,
                              width: double.infinity,
                              height: 230,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
                            )
                          : _buildFallbackBanner(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // TITLE & PRICE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _price,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B6E4F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // SELLER INFORMATION CARD
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFD1FAE5),
                        child: Text(
                          _avatar,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0B6E4F),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _seller,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                            Text(
                              'Campus Peer Seller • Verified Student',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_outlined, color: Color(0xFF0B6E4F)),
                        tooltip: 'Call Seller',
                        onPressed: () => _makePhoneCall(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // TAGS ROW
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _tag,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _condition,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9333EA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // DESCRIPTION BOX
                  Text(
                    'Item Details & Description',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Text(
                      _description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // BOTTOM ACTION BAR WITH CTAS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CHAT WITH BOOK OWNER / RESELLER OWNER BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final String resellerEmail = (widget.product['sellerEmail'] != null && widget.product['sellerEmail']!.isNotEmpty)
                          ? widget.product['sellerEmail']!
                          : 'sneha.cse@campus.edu';

                      final convData = await ApiService.getOrCreateConversation(
                        customerEmail: widget.userEmail,
                        customerName: widget.userName,
                        resellerEmail: resellerEmail,
                        resellerName: _seller,
                        productTitle: _title,
                      );

                      final int? convId = convData != null && convData['conversationId'] != null
                          ? int.tryParse(convData['conversationId'].toString())
                          : null;

                      if (!mounted) return;
                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: convId,
                            sellerName: _seller,
                            productTitle: _title,
                            productPrice: _price,
                            productImage: _image,
                            sellerAvatar: _avatar,
                            currentUserName: widget.userName,
                            currentUserEmail: widget.userEmail,
                            peerEmail: resellerEmail,
                            isReseller: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: Text(
                      'Chat with Book / Reseller Owner',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6E4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // CALL OWNER & PAY NOW (RAZORPAY) BUTTONS ROW
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                cartItems: [
                                  {
                                    'title': _title,
                                    'price': _price,
                                    'seller': _seller,
                                    'tag': _tag,
                                    'image': _image ?? '',
                                  }
                                ],
                                userName: widget.userName,
                                userEmail: widget.userEmail,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Color(0xFF0B6E4F)),
                        label: Text(
                          'Add to Cart',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0B6E4F)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B6E4F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF0B6E4F)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showBuyModal(context);
                        },
                        icon: const Icon(Icons.payment_rounded, size: 16),
                        label: Text(
                          'Pay Now ($_price)',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: const Color(0xFFECFDF5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Color(0xFF0B6E4F),
            ),
            SizedBox(height: 8),
            Text(
              'Verified Campus Item',
              style: TextStyle(
                color: Color(0xFF0B6E4F),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyModal(BuildContext context) {
    RazorpayPaymentModal.show(
      context,
      productTitle: _title,
      amount: _price,
      sellerName: _seller,
      buyerName: widget.userName,
      buyerEmail: widget.userEmail,
      onPaymentSuccess: (paymentId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Razorpay Payment $_price Successful!\nPayment ID: $paymentId • Handover with $_seller'),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0B6E4F),
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    const phoneNumber = '+91 98765 43210';
    final Uri phoneUri = Uri.parse('tel:+919876543210');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {}

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B6E4F), width: 2.5),
                ),
                child: Center(
                  child: Text(
                    _avatar,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0B6E4F)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Calling $_seller...', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(phoneNumber, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0B6E4F), fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
                    },
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Dial App'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_end_rounded, size: 16),
                    label: const Text('End Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
