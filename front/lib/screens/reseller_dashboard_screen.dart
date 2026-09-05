import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../services/inquiry_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';

class ResellerDashboardScreen extends StatefulWidget {
  final String resellerName;
  final String resellerEmail;
  final String resellerMobile;

  const ResellerDashboardScreen({
    super.key,
    this.resellerName = 'Sneha Patel',
    this.resellerEmail = 'sneha.cse@campus.edu',
    this.resellerMobile = '+91 98765 43210',
  });

  @override
  State<ResellerDashboardScreen> createState() => _ResellerDashboardScreenState();
}

class _ResellerDashboardScreenState extends State<ResellerDashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  Function(String)? _activeModalPhotoSetter;
  int _currentBottomNavIndex = 0; // 0: Home, 1: Active Listings, 2: Customer Purchases

  List<Map<String, String>> get _customerInquiries => InquiryService.inquiries;

  void _showCustomerMessagesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final inquiriesList = _customerInquiries;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.forum_rounded, color: Color(0xFF059669), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Inquiries & Chats',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Messages from buyers in Marketplace tab',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: inquiriesList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFECFDF5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 38,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No customer messages yet',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'When buyers message you from the Marketplace tab about your listed books, their messages will appear here.',
                                    style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: inquiriesList.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final chat = inquiriesList[index];
                              final isUnread = chat['unread'] == 'true';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF059669),
                                      child: Text(
                                        chat['avatar'] ?? 'C',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    if (isUnread)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat['customerName'] ?? 'Customer',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      chat['time'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        color: isUnread ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Interested in: ${chat['productTitle']}',
                                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chat['lastMessage'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: isUnread ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  InquiryService.markAsRead(index);
                                  setModalState(() {});
                                  Navigator.pop(context);

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        sellerName: chat['customerName'] ?? 'Customer',
                                        productTitle: chat['productTitle'] ?? 'Product',
                                        productPrice: chat['price'] ?? '₹350',
                                        productImage: chat['image'],
                                        sellerAvatar: chat['avatar'] ?? 'C',
                                        phoneNumber: chat['phone'] ?? '+91 98765 43210',
                                        initialCustomerMessage: chat['lastMessage'],
                                      ),
                                    ),
                                  );
                                },
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

  final List<Map<String, String>> _customerOrders = [
    {
      'orderId': 'order_rzp_984102',
      'title': '📚 Data Structures & Algorithms (Cormen)',
      'price': '₹350',
      'buyerName': 'Hitija Mhatre',
      'buyerEmail': 'student@campus.edu',
      'buyerMobile': '+91 98765 43210',
      'status': 'Booking Confirmed • Library Handover',
      'date': 'Today, 02:30 PM',
      'paymentMode': 'UPI / Razorpay',
      'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
    },
    {
      'orderId': 'order_rzp_884109',
      'title': '⚡ Scientific Calculator Casio FX-991EX',
      'price': '₹600',
      'buyerName': 'Ankit Verma • ECE Dept',
      'buyerEmail': 'ankit.ece@campus.edu',
      'buyerMobile': '+91 91234 56789',
      'status': 'Handover Scheduled at Central Library',
      'date': 'Yesterday, 05:15 PM',
      'paymentMode': 'Campus Wallet',
      'image': 'https://images.unsplash.com/photo-1584697964400-2ae6b27a3523?auto=format&fit=crop&w=800&q=80',
    },
    {
      'orderId': 'order_rzp_774103',
      'title': '🔬 Student Compound Optical Microscope',
      'price': '₹1,200',
      'buyerName': 'Pooja Patel • BioTech Dept',
      'buyerEmail': 'pooja.bio@campus.edu',
      'buyerMobile': '+91 99887 76655',
      'status': 'Reserved • Cash on Pickup',
      'date': '04 Sep 2026',
      'paymentMode': 'Cash on Delivery',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchResellerProducts();
    _fetchCustomerOrders();
  }

  Future<void> _fetchResellerProducts() async {
    final fetched = await ApiService.getProductsBySeller(widget.resellerEmail);
    if (mounted && fetched.isNotEmpty) {
      setState(() {
        for (final item in fetched) {
          final exists = _resellerListings.any((existing) => existing['title'] == item['title']);
          if (!exists) {
            _resellerListings.insert(0, item);
          }
        }
      });
    }
  }

  Future<void> _fetchCustomerOrders() async {
    final fetchedOrders = await ApiService.getAllOrders();
    if (mounted && fetchedOrders.isNotEmpty) {
      setState(() {
        for (final item in fetchedOrders) {
          final exists = _customerOrders.any((existing) => existing['orderId'] == item['orderId']);
          if (!exists) {
            _customerOrders.insert(0, {
              'orderId': item['orderId'] ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
              'title': item['productTitle'] ?? 'Campus Marketplace Book',
              'price': item['price'] ?? '₹350',
              'buyerName': item['buyerName'] ?? 'Campus Student',
              'buyerEmail': item['buyerEmail'] ?? 'student@campus.edu',
              'buyerMobile': '+91 98765 43210',
              'status': 'Purchased • Payment Verified (${item['status'] ?? 'SUCCESS'})',
              'date': item['date'] ?? 'Today',
              'paymentMode': 'Online / Razorpay',
              'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
            });
          }
        }
      });
    }
  }

  Future<XFile?> _pickGalleryImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      try {
        return await _picker.pickMedia();
      } catch (_) {
        return null;
      }
    }
  }

  Future<XFile?> _pickCameraImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Camera picker error: $e');
      return null;
    }
  }

  final List<Map<String, String>> _resellerListings = [
    {
      'title': '📚 Data Structures & Algorithms (Cormen)',
      'price': '₹350',
      'seller': 'Sneha • CSE Dept',
      'tag': 'Engineering',
      'condition': 'Like New',
      'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      'status': 'Active',
      'views': '42 views',
    },
    {
      'title': '⚡ Scientific Calculator Casio FX-991EX',
      'price': '₹600',
      'seller': 'Sneha • CSE Dept',
      'tag': 'Electronics',
      'condition': 'Excellent',
      'image': 'https://images.unsplash.com/photo-1584697964400-2ae6b27a3523?auto=format&fit=crop&w=800&q=80',
      'status': 'Active',
      'views': '89 views',
    },
    {
      'title': '🔬 Student Compound Optical Microscope',
      'price': '₹1,200',
      'seller': 'Sneha • CSE Dept',
      'tag': 'Science',
      'condition': 'Sealed Pack',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=800&q=80',
      'status': 'Reserved',
      'views': '120 views',
    },
  ];

  Widget _buildProductImageWidget(String? pathOrUrl, {required double width, required double height}) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFECFDF5),
        alignment: Alignment.center,
        child: Icon(Icons.cloud_upload_rounded, color: const Color(0xFF059669), size: width * 0.35),
      );
    }

    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://') || pathOrUrl.startsWith('blob:')) {
      return Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFECFDF5),
          alignment: Alignment.center,
          child: Icon(Icons.shopping_bag_outlined, color: const Color(0xFF059669), size: width * 0.35),
        ),
      );
    }

    if (kIsWeb) {
      return Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFECFDF5),
          alignment: Alignment.center,
          child: Icon(Icons.shopping_bag_outlined, color: const Color(0xFF059669), size: width * 0.35),
        ),
      );
    }

    return Image.file(
      File(pathOrUrl),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFECFDF5),
        alignment: Alignment.center,
        child: Icon(Icons.shopping_bag_outlined, color: const Color(0xFF059669), size: width * 0.35),
      ),
    );
  }



  Future<void> _pickPhotoAndOpenUploadModal() async {
    _showAddProductModal(null);
    final XFile? file = await _pickGalleryImage();
    if (file != null && _activeModalPhotoSetter != null) {
      _activeModalPhotoSetter!(file.path);
    }
  }

  void _showAddProductModal([String? initialImagePath]) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String selectedTag = 'Engineering';
    String selectedCondition = 'Like New';
    String? uploadedImagePath = initialImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _activeModalPhotoSetter = (path) {
              setModalState(() {
                uploadedImagePath = path;
              });
            };

            final mediaQuery = MediaQuery.of(context);
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: mediaQuery.viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_a_photo_rounded, color: Color(0xFF059669)),
                            const SizedBox(width: 8),
                            Text(
                              'Upload New Item / Listing',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _activeModalPhotoSetter = null;
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // IMAGE UPLOAD BOX (BLANK BY DEFAULT UNLESS PHOTO PICKED)
                    // IMAGE UPLOAD BOX (BLANK BY DEFAULT UNLESS PHOTO PICKED)
                    Container(
                      width: double.infinity,
                      padding: uploadedImagePath == null ? const EdgeInsets.symmetric(vertical: 14, horizontal: 10) : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: uploadedImagePath != null ? Colors.black : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: uploadedImagePath != null ? Colors.transparent : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: uploadedImagePath != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildProductImageWidget(uploadedImagePath, width: double.infinity, height: 140),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        uploadedImagePath = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final file = await _pickGalleryImage();
                                    if (file != null) {
                                      setModalState(() {
                                        uploadedImagePath = file.path;
                                      });
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFECFDF5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.cloud_upload_rounded, size: 26, color: Color(0xFF059669)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No Photo Selected (Box Blank)',
                                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                      ),
                                      Text(
                                        'Choose picture from gallery or camera below',
                                        style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final file = await _pickGalleryImage();
                                        if (file != null) {
                                          setModalState(() {
                                            uploadedImagePath = file.path;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.photo_library_rounded, size: 15),
                                      label: Text('Open Gallery', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final file = await _pickCameraImage();
                                        if (file != null) {
                                          setModalState(() {
                                            uploadedImagePath = file.path;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.camera_alt_rounded, size: 15, color: Color(0xFF2563EB)),
                                      label: Text('Take Photo', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),

                    // TITLE
                    Text('Product Title', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. 📚 Scientific Calculator FX-991EX or CLRS Book',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PRICE & CATEGORY ROW
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price (₹)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: '₹450',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedTag,
                                items: ['Engineering', 'Commerce', 'Science', 'Electronics', 'Vehicles']
                                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: GoogleFonts.poppins(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) => setModalState(() => selectedTag = val!),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // CONDITION
                    Text('Condition', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Like New', 'Good', 'Sealed Pack'].map((cond) {
                        final isSel = selectedCondition == cond;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cond, style: GoogleFonts.poppins(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                            selected: isSel,
                            selectedColor: const Color(0xFF0B6E4F),
                            onSelected: (sel) {
                              if (sel) setModalState(() => selectedCondition = cond);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // DESCRIPTION
                    Text('Item Details & Description', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Describe edition, battery status, lab usability, etc.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;
                          final String rawTitle = titleController.text.trim();
                          final String newPrice = priceController.text.trim().startsWith('₹')
                              ? priceController.text.trim()
                              : '₹${priceController.text.trim()}';
                          final String finalPrice = newPrice.length > 1 ? newPrice : '₹350';
                          final String imgPath = uploadedImagePath ?? 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80';

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          // Make API Call to Spring Boot Backend
                          final apiRes = await ApiService.createProductListing(
                            title: rawTitle,
                            price: finalPrice,
                            category: selectedTag,
                            condition: selectedCondition,
                            description: descController.text.trim(),
                            sellerName: widget.resellerName,
                            sellerEmail: widget.resellerEmail,
                            imageUrl: imgPath,
                          );

                          if (mounted) {
                            setState(() {
                              _resellerListings.insert(0, {
                                'title': rawTitle,
                                'price': finalPrice,
                                'seller': widget.resellerName,
                                'tag': selectedTag,
                                'condition': selectedCondition,
                                'image': imgPath,
                                'status': 'Active',
                                'views': '1 view',
                              });
                            });

                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(apiRes['message'] ?? '🎉 Product "$rawTitle" published to Campus Marketplace!'),
                                backgroundColor: const Color(0xFF0B6E4F),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text('Publish Product Listing', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B6E4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildUserProfileCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.resellerName.isNotEmpty ? widget.resellerName[0].toUpperCase() : 'P',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF047857)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.resellerName,
                              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              'Reseller (Type 1)',
                              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF047857)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.resellerEmail,
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 6),
                          Text(
                            widget.resellerMobile,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
                          ),
                        ],
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

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total Sales',
            value: '₹4,500',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'Listings',
            value: '${_resellerListings.length}',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            label: 'Items Sold',
            value: '8',
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFF3E8FF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), letterSpacing: -0.5),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Map<String, String> item, {VoidCallback? onDelete}) {
    final title = item['title'] ?? '';
    final price = item['price'] ?? '';
    final tag = item['tag'] ?? '';
    final condition = item['condition'] ?? '';
    final image = item['image'] ?? '';
    final views = item['views'] ?? '0 views';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildProductImageWidget(image, width: 72, height: 72),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      views,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (tag.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (condition.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          condition,
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF9333EA)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFCBD5E1), size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    final title = order['title'] ?? '';
    final price = order['price'] ?? '';
    final buyerName = order['buyerName'] ?? '';
    final buyerEmail = order['buyerEmail'] ?? '';
    final buyerMobile = order['buyerMobile'] ?? '+91 98765 43210';
    final status = order['status'] ?? 'Booking Confirmed';
    final date = order['date'] ?? 'Today';
    final paymentMode = order['paymentMode'] ?? 'Razorpay UPI';
    final image = order['image'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildProductImageWidget(image, width: 54, height: 54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(price, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                          child: Text(paymentMode, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF047857))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(date, style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              const Icon(Icons.person_pin_circle_rounded, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Purchased by: $buyerName ($buyerEmail)',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1D4ED8))),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(buyerMobile, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 0: HOME VIEW (WITH PRODUCT UPLOAD CTA SECTION) ---
  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // USER PROFILE CARD
          _buildUserProfileCard(),
          const SizedBox(height: 20),

          // STATISTICS GRID
          _buildStatsGrid(),
          const SizedBox(height: 16),

          // CUSTOMER BUYER CHATS QUICK ACCESS CARD
          InkWell(
            onTap: () => _showCustomerMessagesModal(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Customer Buyer Inquiries',
                              style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_customerInquiries.where((c) => c['unread'] == 'true').length} New',
                                style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _customerInquiries.isEmpty
                              ? 'No active customer messages yet. Tap to view chats.'
                              : '${_customerInquiries.first['customerName']}: "${_customerInquiries.first['lastMessage']}"',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF059669)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // UPLOAD PRODUCT SECTION (PROMINENTLY GIVEN IN HOME TAB)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withAlpha(50),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Product Listing',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'List books, calculators, lab coats & gear directly from Home.',
                            style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickPhotoAndOpenUploadModal,
                        icon: const Icon(Icons.photo_library_rounded, size: 16),
                        label: Text('Open Gallery & Upload', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddProductModal(null),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
                        label: Text('Add Details Manually', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ACTIVE LISTINGS OVERVIEW PREVIEW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Listings Overview (${_resellerListings.length})',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentBottomNavIndex = 1),
                child: Text(
                  'View All ->',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._resellerListings.take(2).map((item) => _buildListingCard(item)),
          const SizedBox(height: 20),

          // RECENT CUSTOMER PURCHASES PREVIEW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Customer Purchases (${_customerOrders.length})',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentBottomNavIndex = 2),
                child: Text(
                  'View All Orders ->',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._customerOrders.take(2).map((order) => _buildOrderCard(order)),
        ],
      ),
    );
  }

  // --- TAB 1: ACTIVE LISTINGS VIEW ---
  Widget _buildActiveListingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Product Listings (${_resellerListings.length})',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: _pickPhotoAndOpenUploadModal,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text('Upload Item', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_resellerListings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text('No active listings found.', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Upload a product from Home tab to display it here.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            )
          else
            ..._resellerListings.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return _buildListingCard(item, onDelete: () {
                setState(() {
                  _resellerListings.removeAt(idx);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Listing "${item['title']}" deleted.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
            }),
        ],
      ),
    );
  }

  // --- TAB 2: CUSTOMER PURCHASES VIEW ---
  Widget _buildCustomerPurchasesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Purchases & Orders (${_customerOrders.length})',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Verified Payments',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_customerOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text('No customer purchases yet.', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('When buyers purchase your books or calculators, order details appear here.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            )
          else
            ..._customerOrders.map((order) => _buildOrderCard(order)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(),
      _buildActiveListingsView(),
      _buildCustomerPurchasesView(),
    ];

    final String appBarTitle = _currentBottomNavIndex == 1
        ? 'Active Listings'
        : _currentBottomNavIndex == 2
            ? 'Customer Purchases'
            : 'Reseller Home';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        shape: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                _currentBottomNavIndex == 1
                    ? Icons.inventory_2_rounded
                    : _currentBottomNavIndex == 2
                        ? Icons.shopping_bag_rounded
                        : Icons.storefront_rounded,
                color: const Color(0xFF059669),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              appBarTitle,
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          // TOP BAR CHAT BUTTON FOR RESELLER TO SEE CUSTOMER MESSAGES
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Customer Messages & Inquiries',
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF059669), size: 19),
                ),
                onPressed: () => _showCustomerMessagesModal(context),
              ),
              if (_customerInquiries.any((c) => c['unread'] == 'true'))
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      '${_customerInquiries.where((c) => c['unread'] == 'true').length}',
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
          IconButton(
            tooltip: 'Switch View',
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF475569), size: 18),
            ),
            onPressed: () async {
              await SessionService.saveSession(
                isLoggedIn: true,
                userType: 0,
                userName: widget.resellerName,
                userEmail: widget.resellerEmail,
                userRole: 'Student',
              );
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      userName: widget.resellerName,
                      userEmail: widget.resellerEmail,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
            ),
            onPressed: () async {
              await SessionService.clearSession();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_currentBottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, -3),
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
          selectedItemColor: const Color(0xFF059669),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_rounded),
              label: 'Active Listings (${_resellerListings.length})',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_rounded),
              label: 'Customer Purchases',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickPhotoAndOpenUploadModal,
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text(
          'Upload Photo',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
